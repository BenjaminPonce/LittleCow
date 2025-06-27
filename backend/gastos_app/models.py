from django.db import models
from django.contrib.auth.models import User

class Grupo(models.Model):
    nombre = models.CharField(max_length=100)
    jefe = models.ForeignKey(
        User, 
        related_name='grupos_a_cargo', 
        on_delete=models.CASCADE
    )
    integrantes = models.ManyToManyField(
        User, 
        through='IntegranteDeGrupo', 
        related_name='grupos'
    )

    def __str__(self):
        return self.nombre
    
class IntegranteDeGrupo(models.Model):
    usuario = models.ForeignKey(User, on_delete=models.CASCADE)
    grupo = models.ForeignKey(Grupo, on_delete=models.CASCADE)
    ingreso_personal = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    porcentaje = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)  # Porcentaje de participación

    class Meta:
        unique_together = ('usuario', 'grupo')

    def __str__(self):
        return f"{self.usuario.username} en {self.grupo.nombre}"

class GastoCompartido(models.Model):
    monto_total = models.DecimalField(max_digits=12, decimal_places=2)
    distribucion = models.TextField()  # Puedes usar JSONField si quieres guardar la distribución exacta
    grupo = models.ForeignKey(Grupo, on_delete=models.CASCADE, related_name='gastos_compartidos')

    def __str__(self):
        return f"Gasto de {self.monto_total} en {self.grupo.nombre}"

class Reporte(models.Model):
    integrante = models.ForeignKey(IntegranteDeGrupo, on_delete=models.CASCADE, related_name='reportes')
    fecha_de_reporte = models.DateField()
    comentario = models.TextField(blank=True)

    def __str__(self):
        return f"Reporte de {self.integrante.usuario.username} ({self.fecha_de_reporte})"