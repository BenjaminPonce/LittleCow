from rest_framework import serializers
from django.contrib.auth.models import User, Group, Permission
from rest_framework.authtoken.models import Token
from .models import Usuario, Grupo, JefeDeGrupo, IntegranteDeGrupo, GastoCompartido, Reporte

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password']
        extra_kwargs = {'password': {'write_only': True, 'required': True}}

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        Token.objects.create(user=user)
        return user

class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'groups', 'user_permissions']
        extra_kwargs = {
            'password': {'write_only': True},
            'groups': {'read_only': True},
            'user_permissions': {'read_only': True}
        }

    def create(self, validated_data):
        password = validated_data.pop('password', None)
        user = Usuario(**validated_data)
        if password:
            user.set_password(password)
        user.save()
        Token.objects.create(user=user)
        return user

class GrupoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Grupo
        fields = ['id', 'nombre', 'fecha_creacion']
        read_only_fields = ['fecha_creacion']

class JefeDeGrupoSerializer(serializers.ModelSerializer):
    usuario = serializers.PrimaryKeyRelatedField(queryset=Usuario.objects.all())
    grupo = serializers.PrimaryKeyRelatedField(queryset=Grupo.objects.all())

    class Meta:
        model = JefeDeGrupo
        fields = ['id', 'usuario', 'grupo']

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation['usuario'] = UsuarioSerializer(instance.usuario).data
        representation['grupo'] = GrupoSerializer(instance.grupo).data
        return representation

class IntegranteDeGrupoSerializer(serializers.ModelSerializer):
    usuario = serializers.PrimaryKeyRelatedField(queryset=Usuario.objects.all())
    grupo = serializers.PrimaryKeyRelatedField(queryset=Grupo.objects.all())

    class Meta:
        model = IntegranteDeGrupo
        fields = ['id', 'usuario', 'grupo', 'ingreso_personal', 'porcentaje', 'es_jefe']
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
    grupo = serializers.PrimaryKeyRelatedField(queryset=Grupo.objects.all())
    creado_por = serializers.PrimaryKeyRelatedField(queryset=JefeDeGrupo.objects.all(), required=False)

    class Meta:
        model = GastoCompartido
        fields = ['id', 'monto_total', 'metodo_distribucion', 'grupo', 'creado_por', 'fecha_creacion']
        read_only_fields = ['fecha_creacion']
        extra_kwargs = {
            'monto_total': {'min_value': 0.01}
        }

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation['grupo'] = GrupoSerializer(instance.grupo).data
        if instance.creado_por:
            representation['creado_por'] = JefeDeGrupoSerializer(instance.creado_por).data
        return representation

class ReporteSerializer(serializers.ModelSerializer):
    integrante_reportado = serializers.PrimaryKeyRelatedField(queryset=IntegranteDeGrupo.objects.all())
    reportador = serializers.PrimaryKeyRelatedField(queryset=IntegranteDeGrupo.objects.all())

    class Meta:
        model = Reporte
        fields = ['id', 'integrante_reportado', 'reportador', 'fecha_reporte', 'comentario']
        read_only_fields = ['fecha_reporte']

    def to_representation(self, instance):
        representation = super().to_representation(instance)
        representation['integrante_reportado'] = IntegranteDeGrupoSerializer(instance.integrante_reportado).data
        representation['reportador'] = IntegranteDeGrupoSerializer(instance.reportador).data
        return representation