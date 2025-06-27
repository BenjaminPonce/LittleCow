from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from .models import Grupo, IntegranteDeGrupo, GastoCompartido, Reporte
from .serializers import (
    UsuarioSerializer, GrupoSerializer, IntegranteDeGrupoSerializer, 
    GastoCompartidoSerializer, ReporteSerializer
)

# Obtener el modelo de usuario personalizado
Usuario = get_user_model()

class UsuarioViewSet(viewsets.ModelViewSet):
    queryset = Usuario.objects.all()
    serializer_class = UsuarioSerializer

class GrupoViewSet(viewsets.ModelViewSet):
    queryset = Grupo.objects.all()
    serializer_class = GrupoSerializer
    
    @action(detail=True, methods=['get'])
    def integrantes(self, request, pk=None):
        grupo = self.get_object()
        integrantes = IntegranteDeGrupo.objects.filter(grupo=grupo)
        serializer = IntegranteDeGrupoSerializer(integrantes, many=True)
        return Response(serializer.data)

class IntegranteDeGrupoViewSet(viewsets.ModelViewSet):
    queryset = IntegranteDeGrupo.objects.all()
    serializer_class = IntegranteDeGrupoSerializer

class GastoCompartidoViewSet(viewsets.ModelViewSet):
    queryset = GastoCompartido.objects.all()
    serializer_class = GastoCompartidoSerializer

class ReporteViewSet(viewsets.ModelViewSet):
    queryset = Reporte.objects.all()
    serializer_class = ReporteSerializer