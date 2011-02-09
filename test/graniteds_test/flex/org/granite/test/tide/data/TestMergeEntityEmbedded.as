package org.granite.test.tide.data
{
    import org.flexunit.Assert;
    
    import mx.collections.ArrayCollection;
    import mx.events.CollectionEvent;
	import mx.events.PropertyChangeEvent;
    
    import org.granite.tide.BaseContext;
    import org.granite.tide.Tide;
    
    
    public class TestMergeEntityEmbedded 
    {
        private var _ctx:BaseContext = Tide.getInstance().getContext();
        
        
        [Before]
        public function setUp():void {
            Tide.resetInstance();
            _ctx = Tide.getInstance().getContext();
        }
        
        
        [Test]
        public function testMergeEntityEmbedded():void {
			var a1:EmbeddedAddress = new EmbeddedAddress();
			a1.address1 = "12 Main Street";
        	var p1:Person4 = new Person4();
			p1.id = 1;
			p1.uid = "P1";
			p1.version = 0;
			p1.address = a1;
			p1.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, pcHandler);
			a1.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, pcHandler2);
			_ctx.meta_mergeExternalData(p1);
			var a2:EmbeddedAddress = new EmbeddedAddress();
			a2.address1 = "14 Main Street";
        	var p2:Person4 = new Person4();
			p2.id = 1;
			p2.uid = "P1";
			p2.version = 1;
			p2.address = a2;
        	var p:Person4 = _ctx.meta_mergeExternalData(p2) as Person4;
			
			Assert.assertStrictlyEquals("Embedded address merged", p.address, a1);
			Assert.assertFalse("No event on Person", _addrChanged);
			Assert.assertEquals("Address updated", a1.address1, a2.address1);
			Assert.assertTrue("Event on Address", _addrValueChanged);
        }
		
		private var _addrChanged:Boolean = false;
		private var _addrValueChanged:Boolean = false;
		
		private function pcHandler(event:PropertyChangeEvent):void {
			if (event.property == "address")
				_addrChanged = true;
		}
		private function pcHandler2(event:PropertyChangeEvent):void {
			if (event.property == "address1")
				_addrValueChanged = true;
		}
    }
}
