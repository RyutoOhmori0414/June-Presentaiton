using System.Collections.Generic;
using UnityEngine;
using System;

[Serializable]
public class SkillBase
{
    /// <summary>�A�C�e���̃g���[�h���@</summary>
    [SerializeField]
    private TradeType _tradeType;

    public TradeType TradeTyoe => _tradeType;

    /// <summary>Item����ݒ�</summary>
    [SerializeField]
    private string _skillName;

    public string ItemName => _skillName;

    /// <summary>�w�����ɕK�v�ȃA�C�e��</summary>
    [SerializeField]
    private List<string> _requiredItems = new();
    public List<string> GetRequiredItems => _requiredItems;
    /// <summary>�w���ɕK�v�ȋ��z</summary>
    [SerializeField]
    private int _price;
    public int Price => _price;

    SkillBase(string skillName, int price, TradeType tradeType = TradeType.money)
    {
        this._skillName = skillName;
        this._price = price;
        this._tradeType = tradeType;
    }

    /// <summary>�X�L����Effect�̏���</summary>
    public virtual void SkillEffect()
    {

    }

    /// <summary>�����g�p�����w��</summary>
    /// <param name="playerBalance">���݂̎c��</param>
    /// <returns>�����\���ǂ���</returns>
    public bool Condition(int playerBalance)
    {
        if (playerBalance >= _price)
        {//Player�̋������肽��true,����Ȃ�������false
            return true;
        }
        else
        {
            return false;
        }
    }

    /// <summary>���̌���</summary>
    /// <param name="plyerItems">�����i</param>
    /// <returns>�����\���ǂ���</returns>
    public bool Condition(List<string> plyerItems)�@//�w���\���̔���
    {
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
    }

}

