from django.contrib import admin
from .models import Group, Expense, Participation

admin.site.register(Group)
admin.site.register(Expense)
admin.site.register(Participation)