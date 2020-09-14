CREATE ROLE k8spractice_backend;

GRANT USAGE ON SCHEMA k8spractice TO k8spractice_backend;
GRANT SELECT, INSERT, UPDATE ON k8spractice.user to k8spractice_backend;
