package org.granite.test.tide.seam
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ItemResponder;
	import mx.collections.errors.ItemPendingError;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.granite.test.tide.Person;
	import org.granite.tide.BaseContext;
	import org.granite.tide.seam.framework.PagedQuery;
    
    
    public class TestSeamServerPagedQuery 
    {
        private var _ctx:BaseContext = MockSeam.getInstance().getContext();
        
        
        [Before]
        public function setUp():void {
            MockSeam.reset();
            _ctx = MockSeam.getInstance().getSeamContext();
            MockSeam.getInstance().token = new MockSimpleCallAsyncToken();
            MockSeam.getInstance().addComponent("pagedQueryClient", PagedQuery);
        }
        
        
        [Test(async)]
        public function testServerSeamPagedQuery():void {
        	var timer:Timer = new Timer(500);
        	timer.addEventListener(TimerEvent.TIMER, Async.asyncHandler(this, get0Result, 1000), false, 0, true);
        	timer.start();
        	
        	var pagedQuery:PagedQuery = _ctx.pagedQueryClient;
        	pagedQuery.fullRefresh();
        }
        
        private function getFault(fault:Object, token:Object = null):void {
        }
        
        private var cont20:Function;
        
        private function get0Result(event:Object, pass:Object = null):void {
        	var pagedQuery:PagedQuery = _ctx.pagedQueryClient;
        	var person:Person = pagedQuery.getItemAt(0) as Person;
        	Assert.assertEquals("Person id", 0, person.id);
        	
        	var ipe:Boolean = false;
        	try {
        		person = pagedQuery.getItemAt(20) as Person;
        	}
        	catch (e:ItemPendingError) {
        		e.addResponder(new ItemResponder(get20Result, getFault));
        		ipe = true;
        	}
        	Assert.assertTrue("IPE thrown 20", ipe);
        	cont20 = Async.asyncHandler(this, continue20, 1000);
        }
        
        private function get20Result(result:Object, token:Object = null):void {
        	cont20(result);
        }
        
        private function continue20(event:Object, pass:Object = null):void {
        	var pagedQuery:PagedQuery = _ctx.pagedQueryClient;
        	var person:Person = pagedQuery.getItemAt(20) as Person;
        	Assert.assertEquals("Person id", 20, person.id);
        }
    }
}


import flash.utils.Timer;
import flash.events.TimerEvent;
import mx.rpc.AsyncToken;
import mx.rpc.IResponder;
import mx.messaging.messages.IMessage;
import mx.messaging.messages.ErrorMessage;
import mx.messaging.messages.AcknowledgeMessage;
import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;
import mx.collections.ArrayCollection;
import mx.rpc.events.AbstractEvent;
import mx.rpc.events.ResultEvent;
import org.granite.tide.invocation.InvocationCall;
import org.granite.tide.invocation.InvocationResult;
import org.granite.tide.invocation.ContextUpdate;
import org.granite.test.tide.Person;
import org.granite.test.tide.seam.MockSeamAsyncToken;


class MockSimpleCallAsyncToken extends MockSeamAsyncToken {
    
    function MockSimpleCallAsyncToken() {
        super(null);
    }
    
    protected override function buildResponse(call:InvocationCall, componentName:String, op:String, params:Array):AbstractEvent {
        if (componentName == "pagedQueryClient" && op == "refresh") {
        	var coll:ArrayCollection = new ArrayCollection();
        	var first:int = 0;
        	var max:int = 0;
        	for (var j:int = 0; j < call.updates.length; j++) {
        		if (call.updates.getItemAt(j).expression == 'firstResult')
        			first = call.updates.getItemAt(j).value;
        		if (call.updates.getItemAt(j).expression == 'maxResults')
        			max = call.updates.getItemAt(j).value;
        	}
        	if (max == 0)
        		max = 20;
        	for (var i:int = first; i < first+max; i++) {
        		var person:Person = new Person();
        		person.id = i;
        		person.lastName = "Person" + i;
        		coll.addItem(person);
        	}
        	var r:Array = [];
        	for (var k:int = 0; k < call.results.length; k++) {
        		if (call.results[k].componentName != 'pagedQueryClient')
        			continue;
        		if (call.results[k].expression == 'resultCount')
        			r.push([ "pagedQueryClient.resultCount", 1000 ]);
        		if (call.results[k].expression == 'resultList')
        			r.push([ "pagedQueryClient.resultList", coll ]);
        		if (call.results[k].expression == 'firstResult')
        			r.push([ "pagedQueryClient.firstResult", first ]);
        		if (call.results[k].expression == 'maxResults')
        			r.push([ "pagedQueryClient.maxResults", max ]);
        	}
            return buildResult(null, r);
        }
        
        return buildFault("Server.Error");
    }
}
