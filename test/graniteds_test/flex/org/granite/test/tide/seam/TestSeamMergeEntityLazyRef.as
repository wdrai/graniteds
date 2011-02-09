package org.granite.test.tide.seam
{
    import flash.events.Event;
    
    import mx.collections.ArrayCollection;
    import mx.collections.errors.ItemPendingError;
    import mx.core.Application;
    import mx.core.FlexGlobals;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.rpc.Fault;
    import mx.rpc.IResponder;
    
    import org.flexunit.Assert;
    import org.flexunit.async.Async;
    import org.granite.tide.collections.PersistentCollection;
    import org.granite.tide.events.TideResultEvent;
    import org.granite.tide.seam.Context;
    import org.granite.test.tide.Person;
    
    
    public class TestSeamMergeEntityLazyRef
    {
        private var _ctx:Context;
        
        
        private var _person:Person;
        
        [Before]
        public function setUp():void {
            MockSeam.reset();
            _ctx = MockSeam.getInstance().getSeamContext();
            _ctx.application = FlexGlobals.topLevelApplication;
            MockSeam.getInstance().token = new MockSimpleCallAsyncToken(12, "Z48TX", "test");
        }        
        
        [Test(async)]
        public function testMergeEntityLazyRef():void {
            _ctx.personHome.find("test", Async.asyncHandler(this, findResult, 1000));
        }
        
		private var res:Function = null;
		
        private function findResult(event:TideResultEvent, pass:Object = null):void {
            event.context.personHome.instance = event.result as Person;
            
            var coll:PersistentCollection = event.context.personHome.instance.contacts as PersistentCollection;
			res = Async.asyncHandler(this, respondResult, 1000, coll);
			coll.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);
			coll.getItemAt(0);
		}
		
		private function collectionChangeHandler(event:CollectionEvent, pass:Object = null):void {
			if (event.kind == CollectionEventKind.REFRESH)
				res(event);
		}
        
        private function respondResult(event:CollectionEvent, pass:Object = null):void {
			var coll:PersistentCollection = PersistentCollection(event.target);
			Assert.assertTrue(coll.isInitialized());
			Assert.assertEquals(1, coll.length);
			Assert.assertEquals("toto@toto.net", coll.getItemAt(0).email);
        }
        
        private function respondFault(event:Event):void {
			Assert.fail("No response from initializer");
        }
    }
}


import flash.utils.Timer;
import flash.events.TimerEvent;
import mx.rpc.AsyncToken;
import mx.rpc.IResponder;
import mx.messaging.messages.IMessage;
import mx.messaging.messages.ErrorMessage;
import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;
import mx.collections.ArrayCollection;
import mx.rpc.events.AbstractEvent;
import mx.rpc.events.ResultEvent;
import org.granite.tide.invocation.InvocationCall;
import org.granite.tide.invocation.InvocationResult;
import org.granite.tide.invocation.ContextUpdate;
import mx.messaging.messages.AcknowledgeMessage;
import org.granite.test.tide.seam.MockSeamAsyncToken;
import org.granite.test.tide.Person;
import org.granite.test.tide.Contact;
import org.granite.persistence.PersistentSet;


class MockSimpleCallAsyncToken extends MockSeamAsyncToken {
    
    private var _id:Number;
    private var _uid:String;
    private var _name:String;
    
    function MockSimpleCallAsyncToken(id:Number, uid:String, name:String) {
        super(null);
        _id = id;
        _uid = uid;
        _name = name;
    }
    
    protected override function buildResponse(call:InvocationCall, componentName:String, op:String, params:Array):AbstractEvent {
        if (componentName == "personHome" && op == "find") {
            var person:Person = new Person();
            person.id = _id;
            person.uid = _uid;
            person.lastName = _name;
            person.contacts = new PersistentSet(false);
            var re:ResultEvent = buildResult(person);
            re.result.scope = 2;
            re.message.headers["isLongRunningConversation"] = true;
            re.message.headers["conversationId"] = "23";
            return re;
        }
        
        return buildFault("Server.Error");
    }
    
    protected override function buildInitializerResponse(call:InvocationCall, entity:Object, propertyName:String):AbstractEvent {
        if (entity == "personHome.instance" && propertyName == "contacts") {
            var person:Person = new Person();
            person.id = _id;
            person.uid = _uid;
            person.lastName = _name;
            person.contacts = new PersistentSet();
            var contact:Contact = new Contact();
            contact.id = 14;
            contact.email = "toto@toto.net";
            contact.person = person;
            person.contacts.addItem(contact);
            var re:ResultEvent = buildResult(person);
            re.result.scope = 2;
            re.message.headers["isLongRunningConversation"] = true;
            re.message.headers["conversationId"] = "23";
            return re;
        }
        
        return buildFault("Server.LazyInitialization.Error");
    }
}



class SimpleResponder implements IResponder {

	private var _resultHandler:Function;
	private var _faultHandler:Function;
    
	public function SimpleResponder(result:Function, fault:Function) {
		super();

		_resultHandler = result;
		_faultHandler = fault;
	}
	
	public function result(data:Object):void {
		_resultHandler(data);
	}
	
	public function fault(info:Object):void {
		_faultHandler(info);
	}
}