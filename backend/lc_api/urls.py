from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UsuarioViewSet, GrupoViewSet, CrearGrupoCompletoView
from . import views

router = DefaultRouter()
router.register(r'usuarios', UsuarioViewSet, basename='usuario')
router.register(r'grupos', GrupoViewSet, basename='grupo')
router.register(r'jefes-de-grupo', views.JefeDeGrupoViewSet)
router.register(r'integrantes', views.IntegranteDeGrupoViewSet)
router.register(r'gastos', views.GastoCompartidoViewSet)
router.register(r'reportes', views.ReporteViewSet)

urlpatterns = [
    path(
        'grupos/agregar_integrante/',
        GrupoViewSet.as_view({'post': 'agregar_integrante'}),
        name='agregar_integrante'
    ),
    path('grupos/crear_grupo_completo/', CrearGrupoCompletoView.as_view()),
    path('', include(router.urls)),
    path('current-user/', views.CurrentUserView.as_view(), name='current-user'),
    path('mis-grupos/', views.UserGruposView.as_view(), name='user-grupos'),
]