## Generate Custom Internal Root CA

> Needs to be run only once

- create a specific directory to hold the main CA certs

- create a CA key and Certificate

```bash
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -days 3650 -keyout homelabCA.key -out homelabCA.crt -subj "/C=IN/O=My Homelab CA/CN=MyHomelabCA"
```

> add `-nodes` arg to disable passphrase setup for key (not recommended, but required for child certs generated from root cert as applications referring to them should be passphrase blocked).

- now add this to the Certificate Manager on your local PC as a new Root CA.

> The CA key (homelabCA.key) and CA certificate (homelabCA.crt) is now ready to be used to sign server certificates.

## Issue server Certificate using the custom CA

- using the template `cert.cnf`, create a new file for your service with the required arguments.

- Generate a key and CSR

```bash
openssl req -new -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes -keyout tls.key -out tls.csr -config cert.cnf
```

> add `-nodes` arg to disable passphrase setup for key (not recommended).

- Sign the CSR with the CA

```bash
openssl x509 -req -in tls.csr -CA homelabCA.crt -CAkey homelabCA.key -CAcreateserial -nodes -out tls.crt -days 365 -sha256 -extfile cert.cnf -extensions v3_ext
```

- create a combined `tls.pem` file

```bash
cat tls.key tls.crt | tee tls.pem
```

> We can now use this cert for the defined service.
