package org.granite.test.tide.framework
{
    import org.flexunit.Assert;
    
    import org.flexunit.Assert;
    import org.granite.tide.BaseContext;
    import org.granite.tide.Tide;
    import org.granite.tide.events.TideUIConversationEvent;
    import org.granite.tide.events.TideUIEvent;
    
    
    public class TestComponentConversations
    {
        private var _ctx:BaseContext;
        
        
        [Before]
        public function setUp():void {
            Tide.resetInstance();
            _ctx = Tide.getInstance().getContext();
            Tide.getInstance().initApplication();
            Tide.getInstance().addComponents([MyComponentConversation, MyComponentConversation2]);
        }
        
        
        [Test]
        public function testComponentConversations():void {
        	_ctx.application.dispatchEvent(new TideUIConversationEvent("1", "start"));
        	_ctx.application.dispatchEvent(new TideUIConversationEvent("2", "start"));
        	
        	var ctx1:BaseContext = Tide.getInstance().getContext("1", null, false);
        	var ctx2:BaseContext = Tide.getInstance().getContext("2", null, false);
        	
			Assert.assertNull("No global", _ctx.myComponent);
			Assert.assertNotNull("Context 1 created", ctx1);
			Assert.assertNotNull("Context 2 created", ctx2);
        	
			Assert.assertNotNull("Context 1 component", ctx1.myComponent);
			Assert.assertNotNull("Context 2 component", ctx2.myComponent);
			Assert.assertFalse("Component instances", ctx1.myComponent === ctx2.myComponent);
        	
        	ctx1.raiseEvent("next");
			Assert.assertTrue("Component 1 triggered", ctx1.myComponent2.triggered);
			Assert.assertFalse("Component 2 triggered", ctx2.myComponent2.triggered);
        }
    }
}
