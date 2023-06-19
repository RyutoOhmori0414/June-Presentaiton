using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Collider))]
public class PlayerItemManagement : MonoBehaviour
{
    [Tooltip("Player��Item�C���x���g��")]
    [SerializeField] private GameObject _itemBoxCanvas;
    [Tooltip("ItemButtonPreFab, �C���x���g���ɂ���Button")]
    [SerializeField] private GameObject _itemButton;
    [Tooltip("Item���擾������panel")]
    [SerializeField] private GameObject _itemPanel;
    [Tooltip("Player���������Ă���A�C�e��")]
    [SerializeField] public List<string> PlayerItemList = new();
    [Tooltip("Player���������Ă�����z")]
    [SerializeField] public int PlayerMoney = 0;
    private bool _trrigerPrime = false;
    private ItemBase _hitItem;

    private void Start()
    {
        if (_itemBoxCanvas == null || _itemButton == null || _itemPanel == null)
        {
            Debug.Log("�A�^�b�`����Ă��Ȃ��ӏ�������܂�");
        }
    }
    public void KeyProcess(ItemBase _hitObject)
    {
            //ItemBox�̎q�I�u�W�F�N�g�Ƃ���Button�𐶐�����
            var InstantiateObj = Instantiate(_itemButton, _itemBoxCanvas.transform);

            //��������Button��OnClick��ItemBase�̏�����ǉ����Ă���
            InstantiateObj.GetComponent<Button>().onClick.AddListener(() => _hitObject.Action());
            InstantiateObj.GetComponentInChildren<Text>().text = _hitObject.GetItemName;
            Debug.Log("yobareta");
            PlayerItemList.Add(_hitObject.GetItemName);
            //_hitObject.ItemOFF();
            //_itemPanel.SetActive(false);
    }

    // void ItemBoxChanger()
    // {
    //     if (_itemBoxCanvas.activeSelf)
    //     {
    //         if (_hitItem != null)
    //         {
    //             _itemPanel.SetActive(true);
    //         }

    //         _itemBoxCanvas.SetActive(false);
    //     }
    //     else
    //     {
    //         if (_itemPanel.activeSelf)
    //         {
    //             _itemPanel.SetActive(false); 
    //         }

    //         _itemBoxCanvas.SetActive(true);
    //     }
    // }

    // private void Update()
    // {
    //     if (Input.GetKeyDown(KeyCode.B))
    //     {
    //         ItemBoxChanger();
    //     }
    //     if (_hitItem != null && Input.GetKeyDown(KeyCode.F))
    //     {
    //         KeyProcess(_hitItem);
    //     }
    // }

    // private void OnTriggerEnter(Collider other)
    // {
    //     _trrigerPrime = true;
        
    //     if (other.gameObject.TryGetComponent(out ItemBase item))
    //     {
    //         _hitItem = item;
    //     }


    //     // if (_hitItem != null && !_itemBoxCanvas.activeSelf)
    //     // {
    //     //     _itemPanel.SetActive(true);
    //     //     _itemPanel.GetComponentInChildren<Text>().text = $"F {_hitItem.GetItemName}";
    //     // }
    //     //KeyProcess(other.gameObject);
    // }

    // private void OnTriggerExit(Collider other)
    // {
    //     _trrigerPrime = false;
    //     _hitItem = null;

    //     if (_itemPanel.activeSelf)
    //     {
    //         _itemPanel.SetActive(false);
    //     }
    // }

    //void ClickProcess()//���N���b�N���̏���
    //{
    //    Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

    //    if (Physics.Raycast(ray, out RaycastHit hit))
    //    {
    //        //Ray���΂��đΏۂ�ItemBase���p�����Ă����ꍇ�Ɏ��s
    //        if (hit.collider.gameObject.TryGetComponent<ItemBase>(out ItemBase itemBase))
    //        {
    //            //ItemBox�̎q�I�u�W�F�N�g�Ƃ���Button�𐶐�����
    //            var InstantiateObj = Instantiate(_itemButton, _itemCanvas.transform);
    //            //��������Button��OnClick��ItemBase�̏�����ǉ����Ă���
    //            InstantiateObj.GetComponent<Button>().onClick.AddListener(() => itemBase.Action());
    //            InstantiateObj.GetComponentInChildren<Text>().text = itemBase.GetItemName;
    //            _itemList.Add(InstantiateObj);
    //            itemBase.ItemOFF();
    //        }
    //    }
    //}

}