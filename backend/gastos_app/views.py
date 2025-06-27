from django.shortcuts import render
from rest_framework import viewsets
from .models import Grupo, Gasto
from .serializers import GrupoSerializer, GastoSerializer

class GrupoViewSet(viewsets.ModelViewSet):
    queryset = Grupo.objects.all()
    serializer_class = GrupoSerializer

class GastoViewSet(viewsets.ModelViewSet):
    queryset = Gasto.objects.all()
    serializer_class = GastoSerializer