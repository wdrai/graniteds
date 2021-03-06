/*
  GRANITE DATA SERVICES
  Copyright (C) 2011 GRANITE DATA SERVICES S.A.S.

  This file is part of Granite Data Services.

  Granite Data Services is free software; you can redistribute it and/or modify
  it under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  Granite Data Services is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, see <http://www.gnu.org/licenses/>.
*/

package test.granite.ejb3.entity;

import java.util.HashSet;
import java.util.Set;

import javax.persistence.Basic;
import javax.persistence.CascadeType;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;


import test.granite.ejb3.entity.embed.Document;
import test.granite.ejb3.entity.types.DocumentedEntity;
import test.granite.ejb3.entity.types.NamedEntity;

@Entity
public class Person extends AbstractEntity implements NamedEntity, DocumentedEntity {

    private static final long serialVersionUID = 1L;

    @Basic
    private String firstName;

    @Basic
    private String lastName;

    @OneToMany(cascade=CascadeType.ALL, fetch=FetchType.EAGER, mappedBy="person")
    private Set<Contact> contacts = new HashSet<Contact>();

    @OneToOne(cascade=CascadeType.ALL, fetch=FetchType.EAGER)
    private Contact mainContact;

    @Embedded
    private Document document;

    public String getFirstName() {
        return firstName;
    }
    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }
    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public Set<Contact> getContacts() {
        return contacts;
    }
    public void setContacts(Set<Contact> contacts) {
        this.contacts = contacts;
    }

    public Contact getMainContact() {
        return mainContact;
    }
    public void setMainContact(Contact mainContact) {
        this.mainContact = mainContact;
    }

    public Document getDocument() {
        return document;
    }
    public void setDocument(Document document) {
        this.document = document;
    }

    public String getFullName() {
        StringBuilder sb = new StringBuilder();
        if (firstName != null && firstName.length() > 0)
            sb.append(firstName);
        if (lastName != null && lastName.length() > 0) {
            if (sb.length() > 0)
                sb.append(' ');
            sb.append(lastName);
        }
        return sb.toString();
    }
}
