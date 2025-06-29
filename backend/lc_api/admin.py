from django.contrib import admin
from lc_api.models import Usuario, Grupo, JefeDeGrupo, IntegranteDeGrupo, GastoCompartido, Reporte

admin.site.register(IntegranteDeGrupo)
admin.site.register(GastoCompartido)
admin.site.register(Reporte)

@admin.register(Usuario)
class UsuarioAdmin(admin.ModelAdmin):
    list_display = ['username', 'is_active', 'is_staff', 'date_joined']
    list_filter = ['is_active', 'is_staff']
    search_fields = ['username']

@admin.register(Grupo)
class GrupoAdmin(admin.ModelAdmin):
    list_display = ['nombre']
    search_fields = ['nombre']

@admin.register(JefeDeGrupo)
class JefeDeGrupoAdmin(admin.ModelAdmin):
    list_display = ['usuario', 'grupo']
    search_fields = ['usuario__username', 'grupo__nombre']
    autocomplete_fields = ['usuario', 'grupo']  # Mejora el rendimiento