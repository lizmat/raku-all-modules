
import odoorpc

HOST = "localhost"
PORT = 8069
DB   = "sample"
USER = "user@example.com"
PASS = "123"

odoo = odoorpc.ODOO(HOST, port=PORT)

print(odoo.version)
print(odoo.db.list())

uid = odoo.login(DB, USER, PASS)
print(uid)

User = odoo.env['res.users']
user_ids = User.search([])
print(user_ids)

user = User.browse([user_ids[0]])
print(user)
