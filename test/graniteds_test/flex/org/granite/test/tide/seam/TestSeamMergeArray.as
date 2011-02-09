package org.granite.test.tide.seam
{
    import mx.collections.ArrayCollection;
    import mx.collections.IList;
    import mx.rpc.Fault;
    import mx.utils.StringUtil;
    
    import org.flexunit.Assert;
    import org.flexunit.async.Async;
    import org.granite.tide.events.TideFaultEvent;
    import org.granite.tide.events.TideResultEvent;
    import org.granite.tide.seam.Context;
    import org.granite.test.tide.ObjWithArray;
    
    
    public class TestSeamMergeArray
    {
        private var _ctx:Context;
        
        
        private var _obj:ObjWithArray;
        
        [Before]
        public function setUp():void {
            MockSeam.reset();
            _ctx = MockSeam.getInstance().getSeamContext();
            MockSeam.getInstance().token = new MockSimpleCallAsyncToken();
        }        
        
		[Test(async)]
        public function testMergeArray():void {
            _ctx.testArray.find(Async.asyncHandler(this, findResult, 1000));
        }
        
        private function findResult(event:TideResultEvent, pass:Object = null):void {
            _obj = event.result as ObjWithArray;
            Assert.assertEquals(_obj.array.length, Object(MockSeam.getInstance().token).objWithArray.array.length);
            for (var i:int = 0; i < _obj.array.length; i++)
				Assert.assertEquals(Object(MockSeam.getInstance().token).objWithArray.array[i], _obj.array[i]);
            
            _ctx.testArray.add(Async.asyncHandler(this, addResult, 1000));
        }
        
        private function addResult(event:TideResultEvent, pass:Object = null):void {
            _obj = event.result as ObjWithArray;
            
			Assert.assertEquals(_obj.array.length, Object(MockSeam.getInstance().token).objWithArray.array.length+1);
			Assert.assertEquals(_obj.array[_obj.array.length-1], "value1000");
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
import org.granite.test.tide.User;
import org.granite.test.tide.ObjWithArray;


class MockSimpleCallAsyncToken extends MockSeamAsyncToken {
    
    private var _objWithArray:ObjWithArray;
    
    function MockSimpleCallAsyncToken() {
        super(null);
        
        _objWithArray = new ObjWithArray();
        _objWithArray.array = new Array();
        for (var i:int = 0; i < 5; i++) {
            _objWithArray.array.push("value" + i);
        }
    }
    
    public function get objWithArray():ObjWithArray {
        return _objWithArray;
    }
    
    protected override function buildResponse(call:InvocationCall, componentName:String, op:String, params:Array):AbstractEvent {
    	var obj:ObjWithArray = new ObjWithArray();
        if (componentName == "testArray" && op == "find") {
        	obj.name = _objWithArray.name;
        	obj.array = _objWithArray.array.concat();
            return buildResult(obj, null);
        }
        else if (componentName == "testArray" && op == "add") {
        	obj.name = _objWithArray.name;
        	obj.array = _objWithArray.array.concat("value1000");
        	return buildResult(obj, null);
        }
        
        return buildFault("Server.Error");
    }
}
