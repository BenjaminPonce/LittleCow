from django.contrib import admin
from lc_api.models import Usuario, Grupo, IntegranteDeGrupo, GastoCompartido, Reporte

admin.site.register(Usuario)
admin.site.register(Grupo)

admin.site.register(IntegranteDeGrupo)
admin.site.register(GastoCompartido)
admin.site.register(Reporte)