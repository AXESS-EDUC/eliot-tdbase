%{--
  - Copyright © FYLAB and the Conseil Régional d'Île-de-France, 2009
  - This file is part of L'Interface Libre et Interactive de l'Enseignement (Lilie).
  -
  - Lilie is free software. You can redistribute it and/or modify since
  - you respect the terms of either (at least one of the both license) :
  -  under the terms of the GNU Affero General Public License as
  - published by the Free Software Foundation, either version 3 of the
  - License, or (at your option) any later version.
  -  the CeCILL-C as published by CeCILL-C; either version 1 of the
  - License, or any later version
  -
  - There are special exceptions to the terms and conditions of the
  - licenses as they are applied to this software. View the full text of
  - the exception in file LICENSE.txt in the directory of this software
  - distribution.
  -
  - Lilie is distributed in the hope that it will be useful,
  - but WITHOUT ANY WARRANTY; without even the implied warranty of
  - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  - Licenses for more details.
  -
  - You should have received a copy of the GNU General Public License
  - and the CeCILL-C along with Lilie. If not, see :
  -  <http://www.gnu.org/licenses/> and
  -  <http://www.cecill.info/licences.fr.html>.
  --}%
<head>
  <meta name='layout' content='eliot-tdbase-pub'/>
  <title>Login</title>
  <style type='text/css' media='screen'>
  #login {
    margin: 15px 0px;
    padding: 0px;
    text-align: center;
  }

  #login .inner {
    width: 260px;
    margin: 0px auto;
    text-align: left;
    padding: 10px;
    border-top: 1px dashed #499ede;
    border-bottom: 1px dashed #499ede;
    background-color: #EEF;
  }

  #login .inner .fheader {
    padding: 4px;
    margin: 3px 0px 3px 0;
    color: #2e3741;
    font-size: 14px;
    font-weight: bold;
  }

  #login .inner .cssform p {
    clear: left;
    margin: 0;
    padding: 5px 0 8px 0;
    padding-left: 105px;
    border-top: 1px dashed gray;
    margin-bottom: 10px;
    height: 1%;
  }

  #login .inner .cssform input[type='text'] {
    width: 120px;
  }

  #login .inner .cssform label {
    font-weight: bold;
    float: left;
    margin-left: -105px;
    width: 100px;
  }

  #login .inner .login_message {
    color: red;
  }

  #login .inner .text_ {
    width: 120px;
  }

  #login .inner .chk {
    height: 12px;
  }
  </style>
</head>

<body>
<div class="portal-messages">
  <div class="notice" id="news"
       style="margin: 15px 0px;float: left;">
    <g:each in="${grailsApplication.config.eliot.portail.news}" var="annonce">
      ${annonce}<br/>
    </g:each>
  </div>
</div>

<div id='login'>
  <div class='inner'>

    <g:if test='${flash.message}'>
      <div class='login_message'>${flash.message}</div>
    </g:if>
    <div class='fheader'>Merci de vous authentifier..</div>

    <form action='${postUrl}' method='POST' id='loginForm' class='cssform'
          autocomplete='off'>
      <p>
        <label for='username'>Login</label>
        <input type='text' class='text_' name='j_username' id='username'/>
      </p>

      <p>
        <label for='password'>Mot de passe</label>
        <input type='password' class='text_' name='j_password' id='password'/>
      </p>

      <p>
        <label for='remember_me'>Rester connecté</label>
        <input type='checkbox' class='chk' name='${rememberMeParameter}'
               id='remember_me'
               <g:if test='${hasCookie}'>checked='checked'</g:if>/>
      </p>

      <p>
        <input type='submit' value='Login'/>
      </p>
    </form>
  </div>
</div>
<script type='text/javascript'>
  <!--
  (function () {
    document.forms['loginForm'].elements['j_username'].focus();
  })();// -->
</script>
</body>
