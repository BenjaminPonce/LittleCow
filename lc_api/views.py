from rest_framework import viewsets, permissions, status, views, response
from rest_framework.authentication import TokenAuthentication, SessionAuthentication
from django.contrib.auth.models import User
from django.contrib.auth import logout, authenticate, login
from rest_framework.authtoken.models import Token
from .models import Usuario, Grupo, JefeDeGrupo, IntegranteDeGrupo, GastoCompartido, Reporte
from .serializers import (
    UsuarioSerializer, GrupoSerializer, JefeDeGrupoSerializer,
    IntegranteDeGrupoSerializer, GastoCompartidoSerializer, ReporteSerializer
)

## Vistas de autenticación ##

class LoginView(views.APIView):
    permission_classes = [permissions.AllowAny]
    
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        
        user = authenticate(username=username, password=password)
        if user:
            login(request, user)
            token, created = Token.objects.get_or_create(user=user)
            return response.Response({
                'token': token.key,
                'user': UsuarioSerializer(user).data
            }, status=status.HTTP_200_OK)
        return response.Response(
            {'error': 'Credenciales inválidas'}, 
            status=status.HTTP_400_BAD_REQUEST
        )

class LogoutView(views.APIView):
    authentication_classes = [TokenAuthentication, SessionAuthentication]
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        # Eliminar el token de autenticación
        request.user.auth_token.delete()
        logout(request)
        return response.Response(
            {'message': 'Sesión cerrada correctamente'}, 
            status=status.HTTP_200_OK
        )

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

## ViewSets para los modelos ##

class UsuarioViewSet(viewsets.ModelViewSet):
    queryset = Usuario.objects.all()
    serializer_class = UsuarioSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_permissions(self):
        if self.action == 'create':
            return [permissions.AllowAny()]
        return super().get_permissions()

class GrupoViewSet(viewsets.ModelViewSet):
    queryset = Grupo.objects.all()
    serializer_class = GrupoSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]

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

    def perform_create(self, serializer):
        # Asignar automáticamente el jefe que crea el gasto
        jefe = JefeDeGrupo.objects.filter(
            usuario=self.request.user, 
            grupo=serializer.validated_data['grupo']
        ).first()
        serializer.save(creado_por=jefe)

class ReporteViewSet(viewsets.ModelViewSet):
    queryset = Reporte.objects.all()
    serializer_class = ReporteSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [permissions.IsAuthenticated]

## Vistas personalizadas adicionales ##

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
        # Grupos donde el usuario es jefe
        grupos_jefe = Grupo.objects.filter(jefes__usuario=request.user)
        # Grupos donde el usuario es integrante
        grupos_integrante = Grupo.objects.filter(integrantes__usuario=request.user)
        
        jefe_serializer = GrupoSerializer(grupos_jefe, many=True)
        integrante_serializer = GrupoSerializer(grupos_integrante, many=True)
        
        return response.Response({
            'como_jefe': jefe_serializer.data,
            'como_integrante': integrante_serializer.data
        })