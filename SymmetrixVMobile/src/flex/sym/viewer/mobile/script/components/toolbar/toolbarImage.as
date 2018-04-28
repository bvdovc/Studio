import flash.events.MouseEvent;
 
private var _toggleImages:Array = new Array();
private var _currentIndex:int = 0;

private var _enableToggling:Boolean = false;

public override function set source(value:Object):void
{
    super.source = value;
    
    if(_toggleImages == null)
    {
        _toggleImages = [value];
        _currentIndex = 0;
    }
}

[Bindable]
public function get selected():Boolean{
    return _currentIndex > 0;
}

public function set selected(value:Boolean):void{
    _currentIndex = value ? 1 : 0;
    if(this._enableToggling && _toggleImages && _toggleImages.length > 0){
        if(!value)
        {
            this.source = _toggleImages[0]; 
        }
        if(value && _toggleImages.length > 1)
        {
            this.source = _toggleImages[1];
        }
    }
}

public function get currentIndex():int
{
    return _currentIndex;
}

public function set currentIndex(index:int):void
{
    _currentIndex = _currentIndex > (_toggleImages.length - 1) ? 0 : index;
    this.source = _toggleImages[_currentIndex];    
} 

public function set enableToggling(value:Boolean):void{
    this._enableToggling = value;
}

public function set toggleImages(value:Array):void{
    if(!value || value.length == 0){
        throw new Error("ToolBar button toggleImages null or empty reference");
    }
    
    _toggleImages = value;
}

/**
 * switch selected state
 */
protected function image1_clickHandler(event:MouseEvent):void
{ 
    if(_toggleImages.length < 3)
    {
        selected = !selected;
    }
    else if(this._enableToggling)
    { 
        _currentIndex++;
        if(_currentIndex > (_toggleImages.length - 1))
        {
            _currentIndex = 0;
        } 
        this.source = _toggleImages[_currentIndex];
    }
}