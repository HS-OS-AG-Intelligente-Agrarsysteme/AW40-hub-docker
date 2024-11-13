import pytest

from api.data_management import Customer, Case


class TestCustomer:

    @pytest.mark.asyncio
    async def test__remove_id_from_cases(self, initialized_beanie_context):
        async with initialized_beanie_context:
            customer = await Customer(first_name="f", last_name="l").create()
            case = await Case(
                customer_id=customer.id, vehicle_vin="v", workshop_id="w"
                ).create()
            assert case.customer_id == customer.id
            await customer.delete()
            await case.sync()
            assert case.customer_id is None, \
                "Deleted customer's ID should be removed from case."
