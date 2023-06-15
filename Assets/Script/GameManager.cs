using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager
{
    private static GameManager _inctance = null;

    public static GameManager Instance
    {
        get
        {
            _inctance ??= new GameManager();

            return _inctance;
        }
    }

    private CustomInputManager _customInputManager = new CustomInputManager();

    public CustomInputManager CustomInputManager => _customInputManager;
}
