using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ItemStore : MonoBehaviour
{
    /// <summary>PlayerItemManagement</summary>
    private PlayerItemManagement _pim;
    [Tooltip("Player���͈͓��ɂ���Ƃ������ē��p��UI")]
    [SerializeField] private GameObject _infomationUI = null;
    [Tooltip("�A�C�e���X�g�A�Ŕ����Ă���A�C�e��")]
    [SerializeField] private List<GameObject> _sellItem = new();
    [Tooltip("�A�C�e���V���b�v���J���ꂽ���ɂ���Panel(LayoutGroup����)")]
    [SerializeField] private GameObject _shopPanel = null;
    [Tooltip("�V���b�v��panel�ɃC���X�^���X����Button")]
    [SerializeField] private GameObject _button;
    [SerializeField] private GameObject _menuPanel = default;
    private Dictionary<string, GameObject> _sellDic = new();
    private Dictionary<string, GameObject> _buttonDic = new();
    private TradeType _tradeType = TradeType.money;

    private void Start()
    {
        _pim = FindObjectOfType<PlayerItemManagement>();
        GameManager.Instance.CustomInputManager.PlayerControl.PlayerActionMap.Menu.started += _ => _menuPanel.SetActive(!_menuPanel.active);

        _menuPanel.SetActive(false);

        if (_shopPanel == null || _infomationUI == null)
        {
            Debug.Log("�A�^�b�`����Ă��Ȃ����̂�����܂�");
        }

        if (_sellItem != null)
        {
            for (int i = 0; i < _sellItem.Count; i++)
            {
                var button = Instantiate(_button, _shopPanel.transform);
                button.GetComponentInChildren<Text>().text = _sellItem[i].GetComponent<ItemBase>().GetItemName;
                button.GetComponent<Button>().onClick.AddListener(() => Trade(button.GetComponentInChildren<Text>().text));
                _sellDic.Add(_sellItem[i].GetComponent<ItemBase>().GetItemName, _sellItem[i]);
                _buttonDic.Add(_sellItem[i].GetComponent<ItemBase>().GetItemName, button);
            }
        }
    }
    /// <summary>�����Ă���A�C�e�����w���\��Ԃɂ��邩�̔���</summary>
    private void CanSellItem()
    {
        //�����Ă���A�C�e���̌��񔻒胋�[�v
        for (int i = 0; i < _sellItem.Count; i++)
        {
            var sellItemScript = _sellItem[i].GetComponent<ItemBase>();

            //�w���s�̏�Ԃɂ���Ƃ���Button���g�p�s�ɂ���
            if (!sellItemScript.Condition(_pim.PlayerItemList,_pim.PlayerMoney))
            {
                _buttonDic[sellItemScript.GetItemName].GetComponent<Button>().interactable = false;
            }
            else
            {
                _buttonDic[sellItemScript.GetItemName].GetComponent<Button>().interactable = true;
            }
        }
    }
    
    /// <summary>�w������</summary>
    public void Trade(string itemName)
    { 
        var item = _sellDic[itemName].GetComponent<ItemBase>();
        _tradeType = item.GetTradeTyoe;

        switch (_tradeType)
        {
            case TradeType.money:
                _pim.PlayerMoney -= item.GetNeedMoney;
                CanSellItem();
                _pim.KeyProcess(item);
                break;

            case TradeType.item:
                for (int i = 0; i < item.GetRequiredItems.Count; i++)
                {
                    _pim.PlayerItemList.RemoveAt(_pim.PlayerItemList.IndexOf(item.GetRequiredItems[i]));
                }
                _pim.KeyProcess(item);
                CanSellItem();
                break;
        }
    }
    // private void Update()
    // {
    //     //ItemStore���J���ꂽ���Ɏ��s����
    //     if (Input.GetKeyDown(KeyCode.F) && _pim != null)
    //     {
    //         if (_shopPanel.activeSelf)
    //         {
    //             _infomationUI.SetActive(true);
    //             _shopPanel.SetActive(false);
    //         }
    //         else
    //         {
    //             _infomationUI.SetActive(false);
    //             _shopPanel.SetActive(true);
    //             CanSellItem();
    //         }
    //     }
    //     if (Input.GetKeyDown(KeyCode.B))
    //     {
    //         _infomationUI.SetActive(false);
    //     }
    // }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.TryGetComponent(out PlayerItemManagement player))
        {
            _infomationUI.SetActive(true);
            _pim = player;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        _infomationUI.SetActive(false);
        _pim = null;
    }
}