package org.granite.test.tide.data
{
    import org.flexunit.Assert;
    
    import mx.binding.utils.BindingUtils;
    
    import org.granite.math.BigInteger;
    import org.granite.tide.BaseContext;
    import org.granite.tide.Tide;
    
    
    public class TestDirtyCheckEntityBigNumber 
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
        public function testDirtyCheckEntityBigNumber():void {
        	var person:Person7 = new Person7();
        	person.version = 0;
        	person.bigInt = new BigInteger(100);
        	
        	BindingUtils.bindProperty(this, "ctxDirty", _ctx, "meta_dirty");
        	BindingUtils.bindProperty(this, "personDirty", person, "meta_dirty");
        	
        	_ctx.person = _ctx.meta_mergeExternalData(person);
        	
        	Assert.assertFalse("Person not dirty", _ctx.meta_isEntityChanged(person));
        	
        	person.bigInt = new BigInteger(200);
        	
        	Assert.assertTrue("Person dirty", _ctx.meta_isEntityChanged(person));
        	Assert.assertTrue("Person dirty 2", personDirty);
        	Assert.assertTrue("Context dirty", ctxDirty);
        	
        	person.bigInt = new BigInteger(100);
        	
        	Assert.assertFalse("Person not dirty", _ctx.meta_isEntityChanged(person));
        	Assert.assertFalse("Person not dirty 2", personDirty);
        	Assert.assertFalse("Context not dirty", ctxDirty);
        	
        	person.bigInt = null;
        	
        	Assert.assertTrue("Person dirty", _ctx.meta_isEntityChanged(person));
        	Assert.assertTrue("Person dirty 2", personDirty);
        	Assert.assertTrue("Context dirty", ctxDirty);
        	
        	person.bigInt = new BigInteger(100);
        	
        	Assert.assertFalse("Person not dirty", _ctx.meta_isEntityChanged(person));
        	Assert.assertFalse("Person not dirty 2", personDirty);
        	Assert.assertFalse("Context not dirty", ctxDirty);
        }
    }
}
