from rest_framework import viewsets, permissions, status, views, response
from rest_framework.authentication import TokenAuthentication, SessionAuthentication
from django.contrib.auth import logout, authenticate, login
from rest_framework.authtoken.models import Token
from .models import Usuario, Grupo, JefeDeGrupo, IntegranteDeGrupo, GastoCompartido, Reporte
from rest_framework.decorators import action
from rest_framework.response import Response
from .serializers import UsuarioSerializer, GrupoSerializer
from .serializers import (
    UsuarioSerializer, GrupoSerializer, JefeDeGrupoSerializer,
    IntegranteDeGrupoSerializer, GastoCompartidoSerializer, ReporteSerializer
)
from django.contrib.auth import get_user_model
from rest_framework import status
from django.db import transaction
import logging

logger = logging.getLogger(__name__)

User = get_user_model()

class RegisterView(views.APIView):
    permission_classes = [permissions.AllowAny]
    
    def post(self, request):
        serializer = UsuarioSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            if user:
                token = Token.objects.create(user=user)
                return response.Response({
                    'token': token.key,
                    'user': serializer.data
                }, status=status.HTTP_201_CREATED)
        return response.Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )

### 2. ViewSets para Modelos (Corregidos) ###

class UsuarioViewSet(viewsets.ModelViewSet):
    queryset = Usuario.objects.all()
    serializer_class = UsuarioSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_permissions(self):
        if self.action == 'create':
            return [permissions.AllowAny()]
        return super().get_permissions()
    
    def list(self, request):
        queryset = Usuario.objects.all()
        serializer = UsuarioSerializer(queryset, many=True)
        return Response(serializer.data)
    
    permission_classes = [permissions.AllowAny]

class GrupoViewSet(viewsets.ModelViewSet):
    queryset = Grupo.objects.all()
    serializer_class = GrupoSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated] 

    @action(
        detail=True,
        methods=['post'],
        url_path='agregar_integrante',
        url_name='agregar_integrante'
    )
    def agregar_integrante(self, request, *args, **kwargs):  # ¡Cambio crítico aquí!
        try:
            # 1. Obtener el grupo usando self.get_object()
            grupo = self.get_object()  # DRF maneja automáticamente el pk desde la URL
            
            # 2. Validar campo 'username'
            username = request.data.get('username')
            if not username:
                return Response(
                    {'error': 'Username del integrante requerido'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # 3. Buscar usuario
            try:
                usuario = Usuario.objects.get(username=username)
            except Usuario.DoesNotExist:
                return Response(
                    {'error': f'Usuario "{username}" no encontrado'},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # 4. Verificar si ya es integrante
            if IntegranteDeGrupo.objects.filter(usuario=usuario, grupo=grupo).exists():
                return Response(
                    {'error': 'El usuario ya es integrante del grupo'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # 5. Crear integrante
            integrante = IntegranteDeGrupo.objects.create(
                usuario=usuario,
                grupo=grupo,
                porcentaje=0.0,
                ingreso_personal=0.0
            )
            
            return Response({
                'id': integrante.id,
                'message': 'Integrante agregado exitosamente'
            }, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            logger.error(f'Error crítico: {str(e)}', exc_info=True)
            return Response(
                {'error': 'Error interno del servidor'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class JefeDeGrupoViewSet(viewsets.ModelViewSet):
    queryset = JefeDeGrupo.objects.all()
    serializer_class = JefeDeGrupoSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]

class IntegranteDeGrupoViewSet(viewsets.ModelViewSet):
    queryset = IntegranteDeGrupo.objects.all()
    serializer_class = IntegranteDeGrupoSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]

class GastoCompartidoViewSet(viewsets.ModelViewSet):
    queryset = GastoCompartido.objects.all()
    serializer_class = GastoCompartidoSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]

    # Eliminado perform_create ya que no existe 'creado_por' en el modelo

class ReporteViewSet(viewsets.ModelViewSet):
    queryset = Reporte.objects.all()
    serializer_class = ReporteSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]

### 3. Vistas Personalizadas (Corregidas) ###

class CurrentUserView(views.APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        serializer = UsuarioSerializer(request.user)
        return response.Response(serializer.data)

class UserGruposView(views.APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        # Grupos donde el usuario es jefe (corregido)
        grupos_jefe = Grupo.objects.filter(jefe__usuario=request.user)
        
        # Grupos donde el usuario es integrante (corregido)
        grupos_integrante = Grupo.objects.filter(
            integrantedegrupo__usuario=request.user
        )
        
        jefe_serializer = GrupoSerializer(grupos_jefe, many=True)
        integrante_serializer = GrupoSerializer(grupos_integrante, many=True)
        
        return response.Response({
            'como_jefe': jefe_serializer.data,
            'como_integrante': integrante_serializer.data
        })

### 4. Vistas Adicionales para Gestión de Grupos ###

class CrearGrupoCompletoView(views.APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        grupo_serializer = GrupoSerializer(data=request.data)
        if grupo_serializer.is_valid():
            grupo = grupo_serializer.save()
            
            # Crear jefe asociado (corregido)
            jefe = JefeDeGrupo.objects.create(
                usuario=request.user,
                grupo=grupo
            )
            
            return response.Response({
                'grupo': GrupoSerializer(grupo).data,
                'jefe': JefeDeGrupoSerializer(jefe).data
            }, status=status.HTTP_201_CREATED)
        return response.Response(
            grupo_serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )

class AñadirIntegranteView(views.APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request, grupo_id):
        try:
            grupo = Grupo.objects.get(id=grupo_id)
            integrante_data = {
                'usuario': request.data.get('usuario_id'),
                'grupo': grupo.id,
                'ingreso_personal': request.data.get('ingreso_personal', 0),
                'porcentaje': request.data.get('porcentaje', 0)
            }
            
            serializer = IntegranteDeGrupoSerializer(data=integrante_data)
            if serializer.is_valid():
                serializer.save()
                return response.Response(serializer.data, status=status.HTTP_201_CREATED)
            return response.Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        except Grupo.DoesNotExist:
            return response.Response(
                {'error': 'Grupo no encontrado'},
                status=status.HTTP_404_NOT_FOUND
            )