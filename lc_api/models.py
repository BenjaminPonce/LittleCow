from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager

# Manager personalizado para el Usuario
class UsuarioManager(BaseUserManager):
    def create_user(self, username, password=None, **extra_fields):
        if not username:
            raise ValueError('El nombre de usuario es obligatorio')
        user = self.model(username=username, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(username, password, **extra_fields)

# Modelo Usuario personalizado (exactamente como en tu diagrama)
class Usuario(AbstractBaseUser, PermissionsMixin):
    username = models.CharField(max_length=150, unique=True)
    # password ya está incluido en AbstractBaseUser
    
    # Campos necesarios para Django Admin
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(auto_now_add=True)

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = []

    objects = UsuarioManager()

    def __str__(self):
        return self.username

    class Meta:
        verbose_name = "Usuario"
        verbose_name_plural = "Usuarios"

# Modelo intermedio Integrante de grupo según tu diagrama
class IntegranteDeGrupo(models.Model):
    usuario = models.ForeignKey('Usuario', on_delete=models.CASCADE)
    grupo = models.ForeignKey('Grupo', on_delete=models.CASCADE)
    ingreso_personal = models.DecimalField(
        max_digits=12, 
        decimal_places=2, 
        null=True, 
        blank=True
    )
    porcentaje = models.DecimalField(
        max_digits=5, 
        decimal_places=2, 
        null=True, 
        blank=True,
        help_text="Porcentaje de participación en los gastos"
    )
    
    class Meta:
        verbose_name = "Integrante de Grupo"
        verbose_name_plural = "Integrantes de Grupo"
    
    def __str__(self):
        return f"{self.usuario.username} en el grupo {self.grupo.nombre}"


class JefeDeGrupo(models.Model):
    usuario = models.ForeignKey(  # 1 usuario = 1 jefe
        'Usuario', 
        on_delete=models.CASCADE,
        related_name='jefe_de'
    )
    grupo = models.ForeignKey(
        'Grupo',
        on_delete=models.CASCADE,
        related_name='jefe'
    )

    def __str__(self):
        return f"{self.usuario.username}"
    
    class Meta:
        verbose_name = "Jefe de Grupo"
        verbose_name_plural = "Jefes de Grupo"


# Modelo Grupo según tu diagrama
class Grupo(models.Model):
    nombre = models.CharField(max_length=100)
    
    def __str__(self):
        return self.nombre
    
    class Meta:
        verbose_name = "Grupo"
        verbose_name_plural = "Grupos"


# Modelo Gasto compartido según tu diagrama
class GastoCompartido(models.Model):
    TIPOS_DISTRIBUCION = [
        ('EQUITATIVO', 'Equitativo'),
        ('PROPORCIONAL', 'Proporcional'),
        ('PERSONALIZADO', 'Personalizado'),
    ]

    monto_total = models.DecimalField(max_digits=12, decimal_places=2)
    distribucion = models.CharField(max_length=20, choices=TIPOS_DISTRIBUCION)
    grupo = models.ForeignKey(
        'Grupo', 
        on_delete=models.CASCADE, 
        related_name='gastos_compartidos'
    )
    fecha_creacion = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Gasto de ${self.monto_total} en {self.grupo.nombre}"
    
    class Meta:
        verbose_name = "Gasto Compartido"
        verbose_name_plural = "Gastos Compartidos"
        ordering = ['-fecha_creacion']

# Modelo Reporte según tu diagrama
class Reporte(models.Model):
    reportador = models.ForeignKey(
        'IntegranteDeGrupo', 
        on_delete=models.CASCADE,
        related_name='reportes_realizados'
    )
    integrante_reportado = models.ForeignKey(
        'IntegranteDeGrupo', 
        on_delete=models.CASCADE,
        related_name='reportes_recibidos'
    )
    fecha_de_reporte = models.DateField()
    comentario = models.TextField(blank=True)
    
    def __str__(self):
        return f"Reporte de {self.reportador.usuario.username} a {self.integrante_reportado.usuario.username} ({self.fecha_de_reporte})"
    
    class Meta:
        verbose_name = "Reporte"
        verbose_name_plural = "Reportes"
        ordering = ['-fecha_de_reporte']