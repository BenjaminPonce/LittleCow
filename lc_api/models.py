from django.db import models
from django.contrib.auth.models import AbstractUser, Group, Permission
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db.models.signals import post_save
from django.dispatch import receiver

class Usuario(AbstractUser):
    class Meta:
        swappable = 'AUTH_USER_MODEL'
    
    groups = models.ManyToManyField(
        Group,
        verbose_name='groups',
        blank=True,
        help_text='The groups this user belongs to.',
        related_name='custom_user_set',
        related_query_name='custom_user',
    )
    user_permissions = models.ManyToManyField(
        Permission,
        verbose_name='user permissions',
        blank=True,
        help_text='Specific permissions for this user.',
        related_name='custom_user_permissions_set',
        related_query_name='custom_user_permission',
    )

class Grupo(models.Model):
    nombre = models.CharField(max_length=100)
    fecha_creacion = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.nombre

class JefeDeGrupo(models.Model):
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    grupo = models.ForeignKey(Grupo, on_delete=models.CASCADE, related_name='jefes') 
    
    class Meta:
        unique_together = ('usuario', 'grupo')  # Un usuario no puede ser jefe del mismo grupo dos veces
    
    def __str__(self):
        return f"{self.usuario.username} (Jefe de {self.grupo.nombre})"

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
        validators=[
            MinValueValidator(0),
            MaxValueValidator(100)
        ]
    )
    es_jefe = models.BooleanField(default=False)  # Nuevo campo para identificar jefes
    
    class Meta:
        unique_together = ('usuario', 'grupo')

    def __str__(self):
        return f"{self.usuario.username} en {self.grupo.nombre} ({self.porcentaje}%)"

class GastoCompartido(models.Model):
    DISTRIBUCION_CHOICES = [
        ('EQUITATIVO', 'Equitativo'),
        ('PROPORCIONAL', 'Proporcional al ingreso'),
        ('PERSONALIZADO', 'Personalizado'),
    ]
    
    monto_total = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0.01)])
    metodo_distribucion = models.CharField(max_length=20, choices=DISTRIBUCION_CHOICES)
    grupo = models.ForeignKey(Grupo, on_delete=models.CASCADE, related_name='gastos')
    creado_por = models.ForeignKey(JefeDeGrupo, on_delete=models.CASCADE,null=True,default=1)
    fecha_creacion = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Gasto de ${self.monto_total} en {self.grupo.nombre} ({self.get_metodo_distribucion_display()})"

class Reporte(models.Model):
    integrante_reportado = models.ForeignKey(IntegranteDeGrupo, on_delete=models.CASCADE, related_name='reportes_recibidos')
    reportador = models.ForeignKey(IntegranteDeGrupo, on_delete=models.CASCADE, related_name='reportes_hechos')
    fecha_reporte = models.DateTimeField(auto_now_add=True)
    comentario = models.TextField()
    
    def __str__(self):
        return f"Reporte a {self.integrante_reportado.usuario.username} por {self.reportador.usuario.username}"

# Señal para crear automáticamente el integrante cuando se asigna un jefe
@receiver(post_save, sender=JefeDeGrupo)
def crear_integrante_jefe(sender, instance, created, **kwargs):
    if created:
        IntegranteDeGrupo.objects.create(
            usuario=instance.usuario,
            grupo=instance.grupo,
            ingreso_personal=0,  # Valor inicial, puede cambiarse después
            porcentaje=0,  # Valor inicial
            es_jefe=True
        )