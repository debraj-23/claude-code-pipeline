package com.demo.mpmbackend.exception;

public class OrganisationNotFoundException extends RuntimeException {
    public OrganisationNotFoundException(Long id) {
        super("Organisation not found: " + id);
    }
}
