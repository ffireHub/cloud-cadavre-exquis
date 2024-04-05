#!/bin/bash
kubectl exec -it cadavre-exquis-release-postgresql-primary-0 -- psql -U postgres -c "CREATE DATABASE cadavre;"