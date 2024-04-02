#!/bin/bash
kubectl exec -it apps-2-crazy-postgresql-primary-0 -- psql -U postgres -c "CREATE DATABASE cadavre;"