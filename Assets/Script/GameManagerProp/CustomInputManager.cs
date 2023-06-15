using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class CustomInputManager
{
    private InputAction _anyButton = new InputAction(binding: "*/<button>");

    public InputAction AnyButton => _anyButton;

    private PlayerControl _playerControl = new PlayerControl();

    public PlayerControl PlayerControl => _playerControl;

    public CustomInputManager()
    {
        _playerControl.Enable();
        _anyButton.Enable();
    }
}
