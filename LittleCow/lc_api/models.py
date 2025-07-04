from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db.models.signals import post_save

# === Usuario personalizado solo con username y password ===
class UsuarioManager(BaseUserManager):
    def create_user(self, username, password=None, **extra_fields):
        if not username:
            raise ValueError('El nombre de usuario es obligatorio')
        if not extra_fields.get('correo'):
            raise ValueError('El correo es obligatorio')
        if not extra_fields.get('sexo'):
            raise ValueError('El sexo es obligatorio')
        user = self.model(
            username=username,
            correo=extra_fields.get('correo'),
            sexo=extra_fields.get('sexo'),
        )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username, password, **extra_fields):
        user = self.create_user(username, password, **extra_fields)
        user.is_admin = True
        user.save(using=self._db)
        return user

class Usuario(AbstractBaseUser):
    username = models.CharField(max_length=150, unique=True)
    correo = models.CharField(max_length=150, unique=True)
    sexo = models.CharField(max_length=150)
    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)

    objects = UsuarioManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['correo']

    USERNAME_FIELD = 'username'

    def __str__(self):
        return self.username

    @property
    def is_staff(self):
        return self.is_admin

    def has_perm(self, perm, obj=None):
        return self.is_admin

    def has_module_perms(self, app_label):
        return self.is_admin

# === Grupo ===
class Grupo(models.Model):
    nombre = models.CharField(max_length=100)
    fecha_creacion = models.DateTimeField(auto_now_add=True)
    jefe = models.ForeignKey(Usuario, on_delete=models.CASCADE, related_name='grupos_jefe')

    def __str__(self):
        return self.nombre

# === Integrante del grupo ===
class IntegranteDeGrupo(models.Model):
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    grupo = models.ForeignKey(Grupo, on_delete=models.CASCADE, related_name='integrantes')
    ingreso_personal = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(0)]
    )
    porcentaje = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=0,
        validators=[MinValueValidator(0), MaxValueValidator(100)]
    )
    monto_asignado = models.DecimalField(max_digits=10, decimal_places=2, default=0)  # nuevo campo

    class Meta:
        unique_together = ('usuario', 'grupo')

    def __str__(self):
        return f"{self.usuario.username} en {self.grupo.nombre} ({self.porcentaje})"

# === Gasto compartido ===
class GastoCompartido(models.Model):
    DISTRIBUCION_CHOICES = [
        ('EQUITATIVO', 'Equitativo'),
        ('PROPORCIONAL', 'Proporcional al ingreso'),
        ('PERSONALIZADO', 'Personalizado'),
    ]

    monto_total = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0.01)])
    metodo_distribucion = models.CharField(max_length=20, choices=DISTRIBUCION_CHOICES)
    grupo = models.ForeignKey(Grupo, on_delete=models.CASCADE, related_name='gastos')
    creado_por = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    fecha_creacion = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Gasto de ${self.monto_total} en {self.grupo.nombre} ({self.get_metodo_distribucion_display()})"

# === Reporte entre integrantes ===
class Reporte(models.Model):
    integrante_reportado = models.ForeignKey(IntegranteDeGrupo, on_delete=models.CASCADE, related_name='reportes_recibidos')
    reportador = models.ForeignKey(IntegranteDeGrupo, on_delete=models.CASCADE, related_name='reportes_hechos')
    fecha_reporte = models.DateTimeField(auto_now_add=True)
    comentario = models.TextField()

    def __str__(self):
        return f"Reporte a {self.integrante_reportado.usuario.username} por {self.reportador.usuario.username}"