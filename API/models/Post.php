<?php

class Post extends ActiveRecord\Model {

    static $belongs_to = array(
        array('thread')
    );
    
    

}

?>
