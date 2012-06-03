<?php

class Thread extends ActiveRecord\Model {
    
    static $has_many = array(
        array('post','readonly' => true)
    );

    public static function recentThreads($pgNum) {

        $threads = Thread::find('all', array('order' => 'timestamp Desc', 'limit' => 6, 'offset' => $pgNum * 6));
        return $threads;
    }

    public static function to_array($thread) {
        $newThread;

        return $newThread;
    }

}

?>
