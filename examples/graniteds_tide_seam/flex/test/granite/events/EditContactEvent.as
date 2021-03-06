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

package test.granite.events
{
    import flash.events.Event;
    import org.granite.tide.events.AbstractTideEvent;
    
    import test.granite.ejb3.entity.Contact;
    import test.granite.ejb3.entity.Person;
    
    
    public class EditContactEvent extends AbstractTideEvent {
    	
    	public var person:Person;
    	public var contact:Contact;
        
        
        public function EditContactEvent(person:Person, contact:Contact):void {
        	super();
        	this.person = person;
        	this.contact = contact;
        }
        
        public override function clone():Event {
        	return new EditContactEvent(person, contact);
        }
    }
}
