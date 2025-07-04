from django.urls import path
from .views import RegistroUsuarioView, LoginView
from .views import perfil_usuario, grupos_del_usuario, crear_grupo, modificar_gasto, distribuir_gasto, detalle_grupo
from .views import eliminar_integrante, eliminar_grupo, agregar_integrante, salir_de_grupo, reportar_integrante

urlpatterns = [
    path('login/', LoginView.as_view(), name='login'),
    path('register/', RegistroUsuarioView.as_view(), name='register'),
    path('perfil/', perfil_usuario, name='perfil_usuario'),
    path('mis-grupos/', grupos_del_usuario, name='grupos_del_usuario'),
    path('crear-grupo/', crear_grupo, name='crear_grupo'),
    path('grupos/<int:grupo_id>/modificar-gasto/', modificar_gasto),
    path('grupos/<int:grupo_id>/distribuir-gasto/', distribuir_gasto),
    path('detalle-grupo/<int:grupo_id>/', detalle_grupo, name='detalle_grupo'),
    path('grupos/<int:grupo_id>/agregar-integrante/', agregar_integrante, name='agregar_integrante'),
    path('grupos/<int:grupo_id>/eliminar-integrante/', eliminar_integrante, name='eliminar_integrante'),
    path('grupos/<int:grupo_id>/eliminar-grupo/', eliminar_grupo, name='eliminar_grupo'),
    path('grupos/<int:grupo_id>/salir/', salir_de_grupo, name='salir_de_grupo'),
    path('grupos/<int:grupo_id>/reportar/', reportar_integrante, name='reportar_integrante'),

]
