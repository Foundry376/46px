<?php

class Post extends ActiveRecord\Model {

    static $belongs_to = array(
        array('thread'),
        array('user', 'select' => 'id, first_name, last_name')
    );
    
    

}

?>
