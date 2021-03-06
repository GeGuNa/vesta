<?php
/**
 * USERS 
 * 
 * @author Naumov-Socolov <naumov.socolov@gmail.com>
 * @author Malishev Dima <dima.malishev@gmail.com>
 * @author vesta, http://vestacp.com/
 * @copyright vesta 2010-2011
 */
class USER extends AjaxHandler 
{
    
    /**
     * Get list
     * 
     * @param Request $request
     * @return
     */    
    public function getListExecute($request) 
    {
        $reply = array();       
        $result = Vesta::execute(Vesta::V_LIST_SYS_USERS, array(Config::get('response_type')));

        foreach ($result as $ip => $details)
        {
            $reply[] = array(
                'interface' => $details['INTERFACE'],
                'sys_users' => $details['U_SYS_USERS'],
                'web_domains' => $details['U_WEB_DOMAINS'],
                'status' => $details['STATUS'],
                'ip' => $ip,
                'net_mask' => $details['NETMASK'],
                'name' => $details['NAME'],
                'owner' => $details['OWNER'],
                'created_at' => date(Config::get('ui_date_format', strtotime($details['DATE'])))
            );
        }
        
        return $this->reply(true, $result);
    }

    /**
     * Add action
     * 
     * @param Request $request
     * @return
     */
    public function addExecute($_spell = false) 
    {
        $r = new Request();
        if ($_spell)
        {
            $_s = $_spell;
        }
        else
        {
            $_s = $r->getSpell();
        }
        $_user = 'vesta';
        $params = array(
            'USER' => $_s['USER'],
            'PASSWORD' => $_s['PASSWORD'],
            'EMAIL' => $_s['EMAIL'],
            'ROLE' => $_s['ROLE'],
            'OWNER' => $_user,
            'PACKAGE' => $_s['PACKAGE'],
            'NS1' => $_s['NS1'],
            'NS2' => $_s['NS2']
        );

        $result = Vesta::execute(Vesta::V_ADD_SYS_USER, $params);
        if (!$result['status'])
        {
            $this->errors[] = array($result['error_code'] => $result['error_message']);
        }

        return $this->reply($result['status'], $result['data']);
    }

    /**
     * Delete action
     * 
     * @param Request $request
     * @return
     */
    public function delExecute($_spell = false) 
    {
        $r = new Request();
        if ($_spell)
        {
            $_s = $_spell;
        }
        else
        {
            $_s = $r->getSpell();
        }
        $_user = 'vesta';
        $params = array(
                    'USER' => $_s['USER']
                );
        $result = Vesta::execute(Vesta::V_DEL_SYS_USER, $params);

        if (!$result['status'])
        {
          $this->errors[] = array($result['error_code'] => $result['error_message']);
        }

        return $this->reply($result['status'], $result['data']);
    }

    /**
     * Change action
     * 
     * @param Request $request
     * @return
     */
    public function changeExecute($request)
    {
        $r = new Request();
        $_s = $r->getSpell();
        $_old = $_s['old'];
        $_new = $_s['new'];

        $_USER = $_new['USER'];
 
        if($_old['USER'] != $_new['USER'])
        {
            $result = array();
            // creating new user
            $result = $this->addExecute($_new);

            // deleting old
            if ($result['status'])
            {
                $result = array();
            
                $result = $this->delExecute($_old);
                return $this->reply($this->status, '');
            }
        }

        if ($_old['PASSWORD'] != $_new['PASSWORD'])
        {
            $result = array();
            $result = Vesta::execute(Vesta::V_CHANGE_SYS_USER_PASSWORD, 
                            array('USER' => $_USER, 'PASSWORD' => $_new['PASSWORD']));
            if (!$result['status'])
            {
                $this->status = FALSE;
                $this->errors['PASSWORD'] = array($result['error_code'] => $result['error_message']);
            }
        }

        if ($_old['PACKAGE'] != $_new['PACKAGE'])
        {
            $result = array();
            $result = Vesta::execute(Vesta::V_CHANGE_SYS_USER_PACKAGE, 
                                    array('USER' => $_USER, 'PACKAGE' => $_new['PACKAGE']));
            if (!$result['status'])
            {
                $this->status = FALSE;
                $this->errors['PACKAGE'] = array($result['error_code'] => $result['error_message']);
            }
        }

        if ($_old['EMAIL'] != $_new['EMAIL'])
        {
            $result = array();
            $result = Vesta::execute(Vesta::V_CHANGE_SYS_USER_CONTACT, 
                                    array('USER' => $_USER, 'EMAIL' => $_new['EMAIL']));
            if (!$result['status'])
            {
                $this->status = FALSE;
                $this->errors['EMAIL'] = array($result['error_code'] => $result['error_message']);
            }
        }

        if ($_old['NS1'] != $_new['NS1']  || $_old['NS2'] != $_new['NS2'])
        {
            $result = array();
            $result = Vesta::execute(Vesta::V_CHANGE_SYS_USER_NS, 
                                    array('USER' => $_USER, 'NS1' => $_new['NS1'], 'NS2' => $_new['NS2']));
            if (!$result['status'])
            {
                $this->status = FALSE;
                $this->errors['NS'] = array($result['error_code'] => $result['error_message']);
            }
        }

        if ($_old['SHELL'] != $_new['SHELL'])
        {
            $result = array();
            $result = Vesta::execute(Vesta::V_CHANGE_SYS_USER_SHELL, 
                                    array('USER' => $_USER, 'SHELL' => $_new['SHELL']));
            if (!$result['status'])
            {
                $this->status = FALSE;
                $this->errors['SHELL'] = array($result['error_code'] => $result['error_message']);
            }
        }

        if (!$this->status)
        {
            Vesta::execute(Vesta::V_CHANGE_SYS_USER_PASSWORD, array('USER' => $_USER, 'PASSWORD' => $_old['PASSWORD']));
            Vesta::execute(Vesta::V_CHANGE_SYS_USER_PACKAGE,  array('USER' => $_USER, 'PACKAGE' => $_old['PACKAGE']));
            Vesta::execute(Vesta::V_CHANGE_SYS_USER_CONTACT,  array('USER' => $_USER, 'EMAIL' => $_old['EMAIL']));
            // change role //    $result = Vesta::execute(Vesta::V_CHANGE_SYS_USER_PACKAGE, array('USER' => $_USER, 'PACKAGE' => $_new['PACKAGE']));
            Vesta::execute(Vesta::V_CHANGE_SYS_USER_NS,       array('USER' => $_USER, 'NS1' => $_old['NS1'], 'NS2' => $_old['NS2']));
            Vesta::execute(Vesta::V_CHANGE_SYS_USER_SHELL,    array('USER' => $_USER, 'SHELL' => $_old['SHELL']));
        }

        return $this->reply($this->status, '');
    }

}
