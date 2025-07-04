from rest_framework import status, generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view, permission_classes
from django.contrib.auth import authenticate
from .models import Usuario, IntegranteDeGrupo, Grupo, GastoCompartido
from .serializers import UsuarioRegistroSerializer, GrupoCrearSerializer, GastoCompartidoSerializer, ReporteSerializer
from decimal import Decimal

# === Métodos del modelo ===
class LoginView(APIView):
    def post(self, request):
        username = request.data.get("username")
        password = request.data.get("password")
        user = authenticate(username=username, password=password)
        if user:
            token, _ = Token.objects.get_or_create(user=user)
            return Response({"token": token.key})
        return Response({"error": "Credenciales inválidas"}, status=status.HTTP_401_UNAUTHORIZED)

class RegistroUsuarioView(generics.CreateAPIView):
    queryset = Usuario.objects.all()
    serializer_class = UsuarioRegistroSerializer

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def perfil_usuario(request):
    user = request.user
    return Response({
        "id": user.id,
        "username": user.username,
        "is_admin": user.is_admin
    })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def grupos_del_usuario(request):
    usuario = request.user
    integrantes = IntegranteDeGrupo.objects.filter(usuario=usuario).select_related('grupo')
    grupos = [
        {
            "id": i.grupo.id,
            "nombre": i.grupo.nombre,
            "es_jefe": i.grupo.jefe == usuario,
            "ingreso_personal": float(i.ingreso_personal),
            "porcentaje": float(i.porcentaje),
        }
        for i in integrantes
    ]
    return Response(grupos)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def crear_grupo(request):
    serializer = GrupoCrearSerializer(data=request.data)
    if serializer.is_valid():
        ingreso = serializer.validated_data['ingreso_personal']
        grupo = Grupo.objects.create(
            nombre=serializer.validated_data['nombre'],
            jefe=request.user
        )
        # Asegurar creación manual del jefe como integrante con ingreso recibido
        IntegranteDeGrupo.objects.get_or_create(
            usuario=request.user,
            grupo=grupo,
            defaults={'ingreso_personal': ingreso, 'porcentaje': 0}
        )
        # Crear gasto inicial con monto 0 y método vacío
        GastoCompartido.objects.create(
            grupo=grupo,
            monto_total=Decimal('0'),
            metodo_distribucion='',
            creado_por=request.user
        )
        return Response({
            "id": grupo.id,
            "nombre": grupo.nombre,
            "jefe": grupo.jefe.username
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
def modificar_gasto(request, grupo_id):
    try:
        grupo = Grupo.objects.get(id=grupo_id)
        gasto = GastoCompartido.objects.filter(grupo=grupo).order_by('-fecha_creacion').first()

        if not gasto:
            return Response({"error": "No hay gasto para modificar"}, status=404)

        monto_nuevo = request.data.get('monto_total')
        if monto_nuevo is None:
            return Response({"error": "Se requiere monto_total"}, status=400)

        gasto.monto_total = Decimal(str(monto_nuevo))
        gasto.save()

        # Actualizar montos asignados según porcentaje y nuevo monto
        integrantes = grupo.integrantes.all()
        for integrante in integrantes:
            # Calcular nuevo monto asignado proporcional al porcentaje previo
            nuevo_monto = (gasto.monto_total * Decimal(str(integrante.porcentaje))) / Decimal('100')
            integrante.monto_asignado = nuevo_monto.quantize(Decimal('0.01'))
            integrante.save()

        return Response({"mensaje": "Gasto modificado y montos asignados actualizados"}, status=200)
    except Grupo.DoesNotExist:
        return Response({"error": "Grupo no encontrado"}, status=404)
    
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def distribuir_gasto(request, grupo_id):
    try:
        grupo = Grupo.objects.get(id=grupo_id)
        gasto = GastoCompartido.objects.filter(grupo=grupo).order_by('-fecha_creacion').first()

        if not gasto:
            return Response({"error": "No hay gasto para distribuir"}, status=404)

        metodo = request.data.get("metodo_distribucion")
        monto_total = gasto.monto_total
        integrantes = grupo.integrantes.all()

        if metodo == "EQUITATIVO":
            cantidad = integrantes.count()
            if cantidad == 0:
                return Response({"error": "No hay integrantes"}, status=400)
            porcentaje_individual = 100 / cantidad
            monto_individual = monto_total / cantidad
            for i in integrantes:
                i.porcentaje = porcentaje_individual
                i.monto_asignado = monto_individual
                i.save()

        elif metodo == "PERSONALIZADO":
            porcentajes = request.data.get("porcentajes")
            if not porcentajes:
                return Response({"error": "Faltan porcentajes"}, status=400)

            total = sum(float(p) for p in porcentajes.values())
            if abs(total - 100) > 0.01:
                return Response({"error": "La suma debe ser 100%"}, status=400)

            for i in integrantes:
                p = Decimal(str(porcentajes.get(i.usuario.username, 0)))
                i.porcentaje = p
                i.monto_asignado = (monto_total * p) / Decimal('100')
                i.save()
        else:
            return Response({"error": "Método inválido"}, status=400)

        gasto.metodo_distribucion = metodo
        gasto.save()

        return Response({"mensaje": "Distribución aplicada"}, status=200)

    except Grupo.DoesNotExist:
        return Response({"error": "Grupo no encontrado"}, status=404)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def detalle_grupo(request, grupo_id):
    try:
        grupo = Grupo.objects.get(id=grupo_id)

        if not IntegranteDeGrupo.objects.filter(grupo=grupo, usuario=request.user).exists():
            return Response({"error": "No perteneces a este grupo"}, status=403)

        gasto = GastoCompartido.objects.filter(grupo=grupo).order_by('-fecha_creacion').first()
        integrantes = IntegranteDeGrupo.objects.filter(grupo=grupo).select_related('usuario')
        

        return Response({
            "id": grupo.id,
            "nombre": grupo.nombre,
            "jefe": grupo.jefe.username,
            "jefe_correo": grupo.jefe.correo,
            "jefe_sexo": grupo.jefe.sexo,
            "fecha_creacion": grupo.fecha_creacion,
            "es_jefe": grupo.jefe == request.user,
            "gasto": {
                "monto_total": gasto.monto_total,
                "metodo_distribucion": gasto.metodo_distribucion,
                "fecha_creacion": gasto.fecha_creacion,
                "creado_por": gasto.creado_por.username,
            } if gasto else None,
            "integrantes": [
                {
                    "username": i.usuario.username,
                    "ingreso_personal": float(i.ingreso_personal),
                    "porcentaje": float(i.porcentaje),
                    "monto_asignado": float(i.monto_asignado),
                    "es_actual": i.usuario == request.user
                }
                for i in integrantes
            ]
        })

    except Grupo.DoesNotExist:
        return Response({"error": "Grupo no encontrado"}, status=404)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def agregar_integrante(request, grupo_id):
    try:
        grupo = Grupo.objects.get(id=grupo_id)
        if grupo.jefe != request.user:
            return Response({"error": "Solo el jefe puede agregar integrantes"}, status=403)

        username = request.data.get('username')
        ingreso = request.data.get('ingreso_personal')

        if not username or ingreso is None:
            return Response({"error": "Datos incompletos"}, status=400)

        usuario = Usuario.objects.filter(username=username).first()
        if not usuario:
            return Response({"error": "Usuario no encontrado"}, status=404)

        integrante, creado = IntegranteDeGrupo.objects.get_or_create(
            usuario=usuario,
            grupo=grupo,
            defaults={'ingreso_personal': ingreso, 'porcentaje': 0}
        )

        if not creado:
            return Response({"error": "Ya es integrante"}, status=400)

        # Verificar si el grupo tiene un gasto EQUITATIVO
        gasto = grupo.gastos.order_by('-fecha_creacion').first()
        if gasto and gasto.metodo_distribucion == "EQUITATIVO":
            integrantes = grupo.integrantes.all()
            total = integrantes.count()
            if total > 0:
                nuevo_porcentaje = 100 / total
                for i in integrantes:
                    i.porcentaje = nuevo_porcentaje
                    i.save()

        return Response({"mensaje": f"{username} añadido correctamente"}, status=201)

    except Grupo.DoesNotExist:
        return Response({"error": "Grupo no encontrado"}, status=404)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def eliminar_integrante(request, grupo_id):
    try:
        grupo = Grupo.objects.get(id=grupo_id)
        if grupo.jefe != request.user:
            return Response({"error": "Solo el jefe puede eliminar integrantes"}, status=403)

        username = request.data.get("username")
        if not username:
            return Response({"error": "Falta el nombre de usuario"}, status=400)

        usuario = Usuario.objects.filter(username=username).first()
        if not usuario:
            return Response({"error": "Usuario no encontrado"}, status=404)

        if usuario == grupo.jefe:
            return Response({"error": "No se puede eliminar al jefe del grupo"}, status=400)

        eliminado = IntegranteDeGrupo.objects.filter(grupo=grupo, usuario=usuario).delete()
        if eliminado[0] == 0:
            return Response({"error": "Ese usuario no es integrante"}, status=404)

        # Recalcular porcentaje si es EQUITATIVO
        gasto = grupo.gastos.order_by('-fecha_creacion').first()
        if gasto and gasto.metodo_distribucion == "EQUITATIVO":
            integrantes = grupo.integrantes.all()
            total = integrantes.count()
            if total > 0:
                nuevo_porcentaje = 100 / total
                for i in integrantes:
                    i.porcentaje = nuevo_porcentaje
                    i.save()

        return Response({"mensaje": f"{username} eliminado del grupo"}, status=200)

    except Grupo.DoesNotExist:
        return Response({"error": "Grupo no encontrado"}, status=404)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def eliminar_grupo(request, grupo_id):
    try:
        grupo = Grupo.objects.get(id=grupo_id)
        if grupo.jefe != request.user:
            return Response({"error": "Solo el jefe puede eliminar el grupo"}, status=403)

        grupo.delete()
        return Response({"mensaje": "Grupo eliminado correctamente"}, status=200)

    except Grupo.DoesNotExist:
        return Response({"error": "Grupo no encontrado"}, status=404)
    
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def salir_de_grupo(request, grupo_id):
    try:
        grupo = Grupo.objects.get(id=grupo_id)
        if grupo.jefe == request.user:
            return Response({"error": "El jefe no puede salirse del grupo"}, status=400)

        eliminado = IntegranteDeGrupo.objects.filter(grupo=grupo, usuario=request.user).delete()
        if eliminado[0] == 0:
            return Response({"error": "No perteneces a este grupo"}, status=404)

        # Ajustar porcentajes si el último gasto era EQUITATIVO
        gasto = grupo.gastos.order_by('-fecha_creacion').first()
        if gasto and gasto.metodo_distribucion == "EQUITATIVO":
            integrantes = grupo.integrantes.all()
            total = integrantes.count()
            if total > 0:
                nuevo_porcentaje = 100 / total
                for i in integrantes:
                    i.porcentaje = nuevo_porcentaje
                    i.save()

        return Response({"mensaje": "Has salido del grupo"}, status=200)

    except Grupo.DoesNotExist:
        return Response({"error": "Grupo no encontrado"}, status=404)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def reportar_integrante(request, grupo_id):
    try:
        grupo = Grupo.objects.get(id=grupo_id)
    except Grupo.DoesNotExist:
        return Response({"error": "Grupo no encontrado"}, status=404)

    serializer = ReporteSerializer(data=request.data, context={'request': request, 'grupo': grupo})
    if serializer.is_valid():
        serializer.save()
        return Response({"mensaje": "Reporte enviado correctamente"}, status=201)
    return Response(serializer.errors, status=400)