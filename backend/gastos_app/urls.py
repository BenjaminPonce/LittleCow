from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import GrupoViewSet, GastoViewSet

router = DefaultRouter()
router.register(r'grupos', GrupoViewSet)
router.register(r'gastos', GastoViewSet)

urlpatterns = [
    path('', include(router.urls)),
]