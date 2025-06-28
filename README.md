1. Clonar repositorio https://github.com/BenjaminPonce/LittleCow
2. Seleccionar source control (ctrl+shift+G) en el manú de VSC
3. En los 3 puntos que están a la derecha de Título de source control activar los repositorios en caso de que estén desactivados
4. Presionar main en el repositorio LittleCow y seleccionar la branhce origin/Ponce
5. Copiar la dirección donde se clonó el repositorio (en mi caso "C:\Users\pbenj\Desktop\LittleCow")
6. Abrir PowerShell y ingresar a la dirección copiada anteriormente (cd 'C:\Users\pbenj\Desktop\LittleCow')
7. Crear entorno virtual: python -m venv env
8. Entrar en el entorno virtual: env\Scripts\activate
9. Instalar dependencias necesarioas para ejecutar la wea: pip install django psycopg2 djangorestframework django-cors-headers
10. Crear base de datos local en pgAdmin4 y recordar el nombre de la base de datos y el owner especificado. En mi caso la base de datos se llama vaquita_db y el owner es postgres (para la base de datos se utilizara el motor postgreSQL)
11. Ir a la siguiente direccion: ..\LittleCow\backend\backend y abrir settings.py
12. Buscar el siguiente apartado:

    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': 'little_cow_db',
            'USER': 'postgres',
            'PASSWORD': '1234',
            'HOST': 'localhost',
            'PORT': '5432',
        }
    }

Cambiar Name por el nombre que le pusieron a su base de datos, el usuario en el caso de que hayan definido otro y la contraseña tiene que ser la que definieron al momento de instalar postgresSQL. En mi caso quedaría así:

    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': 'vaquita_db',
            'USER': 'postgres',
            'PASSWORD': '1234',
            'HOST': 'localhost',
            'PORT': '5432',
        }
    }

Guardan los cambios del archivo settings.py

13. Volver a PowerShell e ingresar a la carpeta backend: cd .\backend\
14. Ejecutar las siguientes instrucciones de forma separada:
>> python manage.py makemigrations gastos_app
>> python manage.py migrate
15. Crear un usuario administrador para entrar a la página de administración de Django: python manage.py createsuperuser
16. Levantar servidor para backend: python manage.py runserver
17. Abrir el buscador e ingresar la URL que les da la consola al momento de levantar el servidor y agregar un /admin al final (en mi caso es http://127.0.0.1:8000/admin)