# tf-azure-postgres-flex-server

manage azure postgres flexible server with terraform.

## getting started

init project:

```sh
terraform init
```

apply changes:

```sh
terraform apply
```

after deployment, you'll get the database name and server hostname as output. set the hostname as an env var:

```sh
# for example
export PGHOST=postgresql-fs-lion-server.postgres.database.azure.com
```

check if server is accessible with `nslookup` / `nmap`:

```sh
nslookup $PGHOST

nmap -Pn $PGHOST
```

to print the password to the console:

```sh
terraform output -raw db_password
```

login to server with psql after setting the db password as env var:

```sh
# set pass env
export PGPASSWORD=$(terraform output -raw db_password)

# login to server
psql -U postgres
```

after logging in, you can perform standard SQL operations like `select * from your_table;`

following are some common psql commands:

- `\l`: list databases
- `\c dbname`: choose a db
- `\d`: list tables
- `\?`: help
- `\q`: quit

and that's it!

feel free to connect your db to your application, pg admin, etc.

---

## clean up

to remove the resources:

```sh
terraform destroy
```

## notes

- currently the firewall rule allows access from anywhere. please update it accordingly to only allow access from certain IP ranges for better security.

## refs

- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server
- https://learn.microsoft.com/en-us/azure/developer/terraform/deploy-postgresql-flexible-server-database?tabs=azure-cli#6-verify-the-results
