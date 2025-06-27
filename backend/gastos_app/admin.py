from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from django.contrib.auth import get_user_model
from .models import Grupo, IntegranteDeGrupo, GastoCompartido, Reporte

# Obtener el modelo de usuario personalizado
Usuario = get_user_model()

# Formularios personalizados para el Usuario
class UsuarioCreationForm(UserCreationForm):
    class Meta:
        model = Usuario
        fields = ['username']

class UsuarioChangeForm(UserChangeForm):
    class Meta:
        model = Usuario
        fields = ['username', 'is_active', 'is_staff', 'is_superuser']

# Admin personalizado para el Usuario
class UsuarioAdmin(BaseUserAdmin):
    form = UsuarioChangeForm
    add_form = UsuarioCreationForm
    
    # Solo usar campos que realmente existen en tu modelo
    list_display = ['username', 'is_active', 'is_staff', 'is_superuser']
    list_filter = ['is_active', 'is_staff', 'is_superuser']
    
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Permisos', {'fields': ('is_active', 'is_staff', 'is_superuser')}),
    )
    
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'password1', 'password2'),
        }),
    )
    
    search_fields = ['username']
    ordering = ['username']

# Registrar el modelo Usuario con el admin personalizado
admin.site.register(Usuario, UsuarioAdmin)

# Otros modelos
@admin.register(Grupo)
class GrupoAdmin(admin.ModelAdmin):
    list_display = ['nombre', 'jefe']
    search_fields = ['nombre']
    list_filter = ['jefe']

@admin.register(IntegranteDeGrupo)
class IntegranteDeGrupoAdmin(admin.ModelAdmin):
    list_display = ['usuario', 'grupo', 'ingreso_personal', 'porcentaje']
    list_filter = ['grupo']
    search_fields = ['usuario__username', 'grupo__nombre']

@admin.register(GastoCompartido)
class GastoCompartidoAdmin(admin.ModelAdmin):
    list_display = ['monto_total', 'grupo', 'fecha_creacion']
    list_filter = ['grupo', 'fecha_creacion']
    search_fields = ['grupo__nombre']

@admin.register(Reporte)
class ReporteAdmin(admin.ModelAdmin):
    list_display = ['integrante', 'fecha_de_reporte']
    list_filter = ['fecha_de_reporte']
    search_fields = ['integrante__usuario__username']