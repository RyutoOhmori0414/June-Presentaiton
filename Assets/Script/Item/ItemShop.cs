using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.InputSystem;

public class ItemShop : MonoBehaviour
{
    [SerializeField, Tooltip("ItemShopのパネル")]
    private GameObject _shopPanel = default;

    [SerializeField, Tooltip("Buttonとスキル")]
    private ButtonSkillPair[] buttonSkillPairs = default;

    void Start()
    {
        GameManager.Instance.CustomInputManager.PlayerControl.PlayerActionMap.Menu.started += _ => PanelOpen();
        _shopPanel.SetActive(false);
    }

    private void PanelOpen()
    {
        _shopPanel.SetActive(!_shopPanel.active);
    }
}

[System.Serializable]
public struct ButtonSkillPair
{
    [SerializeField]
    private Button _button;

    public Button Button
    {
        get => _button;
        set => _button = value;
    }

    [SerializeField]
    private SkillBase _skill;

    public SkillBase Skill
    {
        get => _skill;
        set => _skill = value;
    }
}
