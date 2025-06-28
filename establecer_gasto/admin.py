from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import Usuario, Grupo, IntegranteDeGrupo, GastoCompartido, Reporte

admin.site.register(Usuario)
admin.site.register(Grupo)
admin.site.register(IntegranteDeGrupo)
admin.site.register(GastoCompartido)
admin.site.register(Reporte)