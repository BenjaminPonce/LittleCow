from rest_framework import serializers
from django.contrib.auth import authenticate
from rest_framework.authtoken.models import Token
from .models import Usuario, Grupo, GastoCompartido, Reporte, IntegranteDeGrupo

# === Login ===
class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    token = serializers.CharField(read_only=True)

    def validate(self, data):
        username = data.get('username')
        password = data.get('password')

        user = authenticate(username=username, password=password)
        if not user:
            raise serializers.ValidationError("Credenciales inválidas")

        # Obtener o crear token
        token, created = Token.objects.get_or_create(user=user)
        data['token'] = token.key
        return data

# === Registro ===
class UsuarioRegistroSerializer(serializers.ModelSerializer):
    username = serializers.CharField(
        required=True,
        error_messages={
            "requiered": "El nombre de usuario es obligatorio.",
            "blank": "El nombre de usuario no puede estar vacio.",
            "unique": "Ya existe un usuario con ese nombre."
        }
    )
    
    correo = serializers.EmailField(
        required=True,
        error_messages={
            "required": "El correo es obligatorio.",
            "blank": "El correo no puede estar vacío.",
            "unique": "Ya existe una cuenta con este correo."
        }
    )

    sexo = serializers.CharField(
        required=True,
        error_messages={
            "required": "El sexo es obligatorio.",
            "blank": "El sexo no puede estar vacío."
        }
    )

    password = serializers.CharField(
        required=True,
        error_messages={
            "required": "La contraseña es obligatoria.",
            "blank": "Ingrese una contraseña."
        }
    )

    class Meta:
        model = Usuario
        fields = ['username', 'password', 'correo', 'sexo']
        extra_kwargs = {'password': {'write_only': True}}

# === Crear grupo ===
class GrupoCrearSerializer(serializers.Serializer):
    nombre = serializers.CharField(max_length=100)
    ingreso_personal = serializers.DecimalField(
        max_digits=10,
        decimal_places=2,
        min_value=0  
    )
    
    class Meta:
        model = Grupo
        fields = ['nombre', 'ingreso_personal']

# === Gasto compartido ===
class GastoCompartidoSerializer(serializers.ModelSerializer):
    grupo = serializers.PrimaryKeyRelatedField(queryset=Grupo.objects.all())
    porcentajes = serializers.DictField(
        child=serializers.FloatField(),
        required=False,
        write_only=True
    )

    class Meta:
        model = GastoCompartido
        fields = ['monto_total', 'metodo_distribucion', 'grupo', 'porcentajes']

    def validate(self, data):
        metodo = data.get('metodo_distribucion')
        porcentajes = data.get('porcentajes', {})

        if metodo == 'PERSONALIZADO':
            if not porcentajes:
                raise serializers.ValidationError("Debe proporcionar los porcentajes para distribución personalizada.")
            if not isinstance(porcentajes, dict):
                raise serializers.ValidationError("El campo porcentajes debe ser un diccionario.")

            total = sum(porcentajes.values())
            if abs(total - 100) > 0.01:
                raise serializers.ValidationError("La suma de los porcentajes debe ser exactamente 100.")

            for username, porcentaje in porcentajes.items():
                if porcentaje < 0 or porcentaje > 100:
                    raise serializers.ValidationError(f"El porcentaje de {username} debe estar entre 0 y 100.")

        return data

# === Reporte ===
class ReporteSerializer(serializers.ModelSerializer):
    reportado_username = serializers.CharField(write_only=True)
    comentario = serializers.CharField()

    class Meta:
        model = Reporte
        fields = ['reportado_username', 'comentario']

    def validate(self, data):
        request = self.context['request']
        usuario_reportador = request.user
        grupo = self.context['grupo']

        try:
            reportador = IntegranteDeGrupo.objects.get(usuario=usuario_reportador, grupo=grupo)
        except IntegranteDeGrupo.DoesNotExist:
            raise serializers.ValidationError("Debes ser integrante del grupo.")

        try:
            reportado_user = Usuario.objects.get(username=data['reportado_username'])
            reportado = IntegranteDeGrupo.objects.get(usuario=reportado_user, grupo=grupo)
        except (Usuario.DoesNotExist, IntegranteDeGrupo.DoesNotExist):
            raise serializers.ValidationError("El usuario reportado no pertenece a este grupo.")

        data['reportador'] = reportador
        data['integrante_reportado'] = reportado
        return data

    def create(self, validated_data):
        validated_data.pop('reportado_username')
        return Reporte.objects.create(**validated_data)
