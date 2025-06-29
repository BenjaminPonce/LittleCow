from rest_framework import serializers
from .models import Usuario, Grupo, JefeDeGrupo, IntegranteDeGrupo, GastoCompartido, Reporte

class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'username', 'is_active', 'is_staff', 'date_joined']
        extra_kwargs = {
            'password': {'write_only': True},
            'is_active': {'read_only': True},
            'is_staff': {'read_only': True},
            'date_joined': {'read_only': True}
        }

    def create(self, validated_data):
        password = validated_data.pop('password', None)
        user = Usuario(**validated_data)
        if password:
            user.set_password(password)
        user.save()
        return user

class JefeDeGrupoSerializer(serializers.ModelSerializer):
    class Meta:
        model = JefeDeGrupo
        fields = ['id', 'usuario']
    
    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation['usuario'] = UsuarioSerializer(instance.usuario).data
        return representation

class GrupoSerializer(serializers.ModelSerializer):
    jefe = serializers.PrimaryKeyRelatedField(
        queryset=JefeDeGrupo.objects.all(), 
        allow_null=True
    )
    
    class Meta:
        model = Grupo
        fields = ['id', 'nombre', 'jefe', 'fecha_creacion']
        read_only_fields = ['fecha_creacion']
    
    def to_representation(self, instance):
        representation = super().to_representation(instance)
        if instance.jefe:
            representation['jefe'] = JefeDeGrupoSerializer(instance.jefe).data
        return representation

class IntegranteDeGrupoSerializer(serializers.ModelSerializer):
    class Meta:
        model = IntegranteDeGrupo
        fields = ['id', 'usuario', 'grupo', 'ingreso_personal', 'porcentaje']
        extra_kwargs = {
            'porcentaje': {'min_value': 0, 'max_value': 100},
            'ingreso_personal': {'min_value': 0}
        }
    
    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation['usuario'] = UsuarioSerializer(instance.usuario).data
        representation['grupo'] = GrupoSerializer(instance.grupo).data
        return representation

class GastoCompartidoSerializer(serializers.ModelSerializer):
    class Meta:
        model = GastoCompartido
        fields = ['id', 'monto_total', 'distribucion', 'grupo', 'fecha_creacion']
        read_only_fields = ['fecha_creacion']
        extra_kwargs = {
            'monto_total': {'min_value': 0.01}
        }
    
    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation['grupo'] = GrupoSerializer(instance.grupo).data
        return representation

class ReporteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reporte
        fields = ['id', 'integrante_reportado', 'reportador', 'fecha_de_reporte', 'comentario']
        read_only_fields = ['fecha_de_reporte']
    
    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation['integrante_reportado'] = IntegranteDeGrupoSerializer(
            instance.integrante_reportado
        ).data
        representation['reportador'] = IntegranteDeGrupoSerializer(
            instance.reportador
        ).data
        return representation