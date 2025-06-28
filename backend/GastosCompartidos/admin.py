from django.contrib import admin
from .models import Usuario, IntegranteDeGrupo, Grupo, JefeDeGrupo, GastoCompartido, Reporte

admin.site.register(Usuario)
admin.site.register(IntegranteDeGrupo)
admin.site.register(Grupo)
admin.site.register(JefeDeGrupo)
admin.site.register(GastoCompartido)
admin.site.register(Reporte)