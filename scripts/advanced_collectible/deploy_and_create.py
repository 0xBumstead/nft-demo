from scripts.helpful_scripts import get_account, get_contract, OPENSEA_URL
from brownie import AdvancedCollectible, network, config


def deploy_and_create():
    account = get_account()
    advanced_collectible = AdvancedCollectible.deploy(
        get_contract("vrf_coordinator"),
        get_contract("link_token"),
        config["networks"][network.show_active()]["keyhash"],
        config["networks"][network.show_active()]["fee"],
        {"from": account},
    )
    print(
        f"Awesome, you can view your NFT at {OPENSEA_URL.format(advanced_collectible.address, advanced_collectible.tokenCounter()-1)}"
    )
    return advanced_collectible


def main():
    deploy_and_create()
