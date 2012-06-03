<?php

class Thread extends ActiveRecord\Model {
    
    static $has_many = array(
        array('post','readonly' => true, 'select' => 'id, user_id, caption, timestamp, image_url')
    );

    public static function recentThreads($pgNum) {

        $threads = Thread::find('all', array('order' => 'timestamp Desc', 'limit' => 6, 'offset' => $pgNum * 6));
        return $threads;
    }
}

?>
