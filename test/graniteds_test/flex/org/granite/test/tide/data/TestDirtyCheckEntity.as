package org.granite.test.tide.data
{
    import org.flexunit.Assert;
    
    import mx.binding.utils.BindingUtils;
    import mx.collections.ArrayCollection;
    
    import org.granite.tide.BaseContext;
    import org.granite.tide.Tide;
    import org.granite.test.tide.Contact;
    import org.granite.test.tide.Person;
    
    
    public class TestDirtyCheckEntity 
    {
        private var _ctx:BaseContext = Tide.getInstance().getContext();
        
        
        [Before]
        public function setUp():void {
            Tide.resetInstance();
            _ctx = Tide.getInstance().getContext();
        }
        
        
        public var ctxDirty:Boolean;
        public var personDirty:Boolean;
        
        [Test]
        public function testDirtyCheckEntity():void {
        	var person:Person = new Person();
        	var person2:Person = new Person(); 
        	
        	BindingUtils.bindProperty(this, "ctxDirty", _ctx, "meta_dirty");
        	BindingUtils.bindProperty(this, "personDirty", person, "meta_dirty");
        	
        	person.contacts = new ArrayCollection();
        	person.version = 0;
        	var contact:Contact = new Contact();
        	contact.version = 0;
        	contact.person = person;
        	person.contacts.addItem(contact);
        	person2.version = 0;
        	_ctx.contact = _ctx.meta_mergeExternal(contact);
        	_ctx.person2 = _ctx.meta_mergeExternal(person2);
        	contact = _ctx.contact;
        	person2 = _ctx.person2;
        	contact.person.firstName = 'toto';
        	
        	Assert.assertTrue("Person dirty", _ctx.meta_isEntityChanged(contact.person));
        	Assert.assertTrue("Person dirty 2", personDirty);
        	Assert.assertTrue("Context dirty", _ctx.meta_dirty);
        	Assert.assertTrue("Context dirty 2", ctxDirty);
        	Assert.assertFalse("Contact not dirty", _ctx.meta_isEntityChanged(contact));
        	
        	contact.person.firstName = null;
        	
        	Assert.assertFalse("Person not dirty", _ctx.meta_isEntityChanged(contact.person));
        	Assert.assertFalse("Person not dirty 2", personDirty);
        	Assert.assertFalse("Context not dirty", _ctx.meta_dirty);
        	Assert.assertFalse("Context not dirty 2", ctxDirty);
        	Assert.assertFalse("Contact not dirty", _ctx.meta_isEntityChanged(contact));
        	
        	var contact2:Contact = new Contact();
        	contact2.version = 0;
        	contact2.person = person;
        	person.contacts.addItem(contact2);
        	        	
        	Assert.assertTrue("Person dirty", _ctx.meta_isEntityChanged(contact.person));
        	Assert.assertTrue("Person dirty 2", personDirty);
        	Assert.assertTrue("Context dirty", _ctx.meta_dirty);
        	Assert.assertTrue("Context dirty 2", ctxDirty);
        	Assert.assertFalse("Contact not dirty", _ctx.meta_isEntityChanged(contact));
        	
        	person.contacts.removeItemAt(1);
        	
        	Assert.assertFalse("Person not dirty", _ctx.meta_isEntityChanged(contact.person));
        	Assert.assertFalse("Person not dirty 2", personDirty);
        	Assert.assertFalse("Context not dirty", _ctx.meta_dirty);
        	Assert.assertFalse("Context not dirty 2", ctxDirty);
        	Assert.assertFalse("Contact not dirty", _ctx.meta_isEntityChanged(contact));
        	
        	contact.email = "toto";
        	person2.lastName = "tutu";
        	
        	Assert.assertTrue("Contact dirty", _ctx.meta_isEntityChanged(contact));
        	Assert.assertTrue("Person 2 dirty", _ctx.meta_isEntityChanged(person2));
        	
        	var receivedPerson:Person = new Person();
        	receivedPerson.version = 1;
        	receivedPerson.uid = person.uid;
        	var receivedContact:Contact = new Contact();
        	receivedContact.version = 1;
        	receivedContact.uid = contact.uid;
        	receivedContact.person = receivedPerson;
        	receivedPerson.contacts = new ArrayCollection();
        	receivedPerson.contacts.addItem(receivedContact);
        	
        	_ctx.meta_result(null, null, null, receivedPerson);
        	
        	Assert.assertFalse("Contact not dirty", _ctx.meta_isEntityChanged(contact));
        	Assert.assertTrue("Person 2 dirty", _ctx.meta_isEntityChanged(person2));
        	Assert.assertTrue("Context dirty", _ctx.meta_dirty);
        	
        	receivedPerson = new Person();
        	receivedPerson.version = 1;
        	receivedPerson.uid = person2.uid;
        	
        	_ctx.meta_result(null, null, null, receivedPerson);
        	Assert.assertFalse("Person 2 dirty", _ctx.meta_isEntityChanged(person2));
        	Assert.assertFalse("Context dirty", _ctx.meta_dirty);
        }
    }
}
