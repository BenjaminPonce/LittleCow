from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    UsuarioViewSet, GrupoViewSet, IntegranteDeGrupoViewSet, 
    GastoCompartidoViewSet, ReporteViewSet  # ← Nota: GastoCompartidoViewSet, NO GastoViewSet
)

router = DefaultRouter()
router.register(r'usuarios', UsuarioViewSet)
router.register(r'grupos', GrupoViewSet)
router.register(r'integrantes', IntegranteDeGrupoViewSet)
router.register(r'gastos-compartidos', GastoCompartidoViewSet)  # ← Corregido
router.register(r'reportes', ReporteViewSet)

urlpatterns = [
    path('', include(router.urls)),
]