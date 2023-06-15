using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

/// <summary>�g���[�h���@</summary>
public enum TradeType
{
    money,
    item
}
public abstract class ItemBase : MonoBehaviour
{
    [Tooltip("�A�C�e���̃g���[�h���@")]
    [SerializeField] private TradeType _tradeType = TradeType.money;
    public TradeType GetTradeTyoe => _tradeType;
    [Tooltip("Item����ݒ�")]
    [SerializeField] private string _itemName;
    public string GetItemName => _itemName;
    [Tooltip("�w�����ɕK�v�ȃA�C�e��")]
    [SerializeField] private List<string> _requiredItems = new();
    public List<string> GetRequiredItems => _requiredItems;
    [Tooltip("�w���ɕK�v�ȋ��z")]
    [SerializeField] private int _needMoney = 10;
    public int GetNeedMoney => _needMoney;


    private void Start()
    {
        if (_itemName == null || GetItemName == null)
        {
            Debug.Log("Item����Null�ł�");
        }
    }

    /// <summary>�C���x���g���őI�����ꂽ���̏���</summary>
    public abstract void Action(); 

    /// <summary>�w���\���̔���(Player�̏����i, Player�̏�����) </summary
    public bool Condition(List<string> plyerItems, int playerMonay)�@//�w���\���̔���
    {
        switch (_tradeType)
        {
            case TradeType.item:
                var tempList = new List<string>(plyerItems);
                for (int i = 0; i < _requiredItems.Count; i++) //�w���ɕK�v�ȃA�C�e���̕����[�v
                {
                    if (!tempList.Contains(_requiredItems[i]))
                    {//�K�v�ȃA�C�e������ł��Ȃ������Ƃ��AFalse��Ԃ��ă��[�v���I��
                        return false;
                    }
                    else
                    {//�K�v�ȃA�C�e�����������Ƃ��ɃR�s�[�������X�g���烊���[�u���Ď��̔���
                        tempList.RemoveAt(tempList.IndexOf(_requiredItems[i]));
                    }
                }
                return true;

            case TradeType.money:
                if (playerMonay >= _needMoney)
                {//Player�̋������肽��true,����Ȃ�������false
                    return true;
                }
                else
                {
                    return false;
                }
            default :
                return false;
        }
        
    }

    /// <summary>Item���C���x���g���ɒǉ����ꂽ���Ɏ��s, �`��̒�~</summary>
    public void ItemOFF() 
    {
        //Collider��Renderer��False�ɂ��Ĕ���̎擾�ƕ`����~�߂Ă���
        GetComponent<Collider>().enabled = false;
        GetComponent<MeshRenderer>().enabled = false;
    }
}
