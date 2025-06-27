from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Grupo, IntegranteDeGrupo, GastoCompartido, Reporte

# Obtener el modelo de usuario personalizado
Usuario = get_user_model()

class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'username', 'is_active', 'date_joined']
        extra_kwargs = {'password': {'write_only': True}}

class IntegranteDeGrupoSerializer(serializers.ModelSerializer):
    usuario = UsuarioSerializer(read_only=True)
    usuario_id = serializers.IntegerField(write_only=True)
    
    class Meta:
        model = IntegranteDeGrupo
        fields = ['id', 'usuario', 'usuario_id', 'grupo', 'ingreso_personal', 'porcentaje']

class GrupoSerializer(serializers.ModelSerializer):
    jefe = UsuarioSerializer(read_only=True)
    jefe_id = serializers.IntegerField(write_only=True)
    integrantes = IntegranteDeGrupoSerializer(source='integrantedegrupo_set', many=True, read_only=True)
    
    class Meta:
        model = Grupo
        fields = ['id', 'nombre', 'jefe', 'jefe_id', 'integrantes']

class GastoCompartidoSerializer(serializers.ModelSerializer):
    grupo_nombre = serializers.CharField(source='grupo.nombre', read_only=True)
    
    class Meta:
        model = GastoCompartido
        fields = ['id', 'monto_total', 'distribucion', 'grupo', 'grupo_nombre', 'fecha_creacion']

class ReporteSerializer(serializers.ModelSerializer):
    integrante_nombre = serializers.CharField(source='integrante.usuario.username', read_only=True)
    
    class Meta:
        model = Reporte
        fields = ['id', 'integrante', 'integrante_nombre', 'fecha_de_reporte', 'comentario']